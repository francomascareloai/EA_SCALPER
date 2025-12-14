"""
Model Training for Direction Prediction
EA_SCALPER_XAUUSD - Singularity Edition

LSTM model for price direction prediction with Walk-Forward Analysis
"""
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader, TensorDataset
from typing import Tuple, List, Optional
from pathlib import Path
import json
from datetime import datetime

from .config import DIRECTION_CONFIG, TRAINING_CONFIG, MODELS_DIR


class DirectionLSTM(nn.Module):
    """LSTM model for direction prediction"""
    
    def __init__(
        self,
        input_size: int = 15,
        hidden_size: int = 64,
        num_layers: int = 2,
        dropout: float = 0.2,
        output_size: int = 2
    ):
        super().__init__()
        
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        
        self.lstm = nn.LSTM(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            dropout=dropout if num_layers > 1 else 0,
            batch_first=True
        )
        
        self.fc = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(32, output_size)
        )
        
    def forward(self, x):
        # x shape: (batch, sequence, features)
        lstm_out, _ = self.lstm(x)
        # Take last timestep
        last_hidden = lstm_out[:, -1, :]
        # Output probabilities
        logits = self.fc(last_hidden)
        return F.softmax(logits, dim=1)


class DirectionGRU(nn.Module):
    """GRU model (lighter alternative to LSTM)"""
    
    def __init__(
        self,
        input_size: int = 15,
        hidden_size: int = 64,
        num_layers: int = 2,
        dropout: float = 0.2,
        output_size: int = 2
    ):
        super().__init__()
        
        self.gru = nn.GRU(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            dropout=dropout if num_layers > 1 else 0,
            batch_first=True
        )
        
        self.fc = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(32, output_size)
        )
        
    def forward(self, x):
        gru_out, _ = self.gru(x)
        last_hidden = gru_out[:, -1, :]
        logits = self.fc(last_hidden)
        return F.softmax(logits, dim=1)


class ModelTrainer:
    """Handles model training with early stopping"""
    
    def __init__(
        self,
        model: nn.Module,
        learning_rate: float = 1e-4,
        device: str = None
    ):
        self.model = model
        self.device = device or ('cuda' if torch.cuda.is_available() else 'cpu')
        self.model.to(self.device)
        
        self.optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
        self.criterion = nn.CrossEntropyLoss()
        
        self.train_losses = []
        self.val_losses = []
        self.best_val_loss = float('inf')
        self.best_model_state = None
        
    def train_epoch(self, dataloader: DataLoader) -> float:
        """Train for one epoch"""
        self.model.train()
        total_loss = 0
        
        for X_batch, y_batch in dataloader:
            X_batch = X_batch.to(self.device)
            y_batch = y_batch.to(self.device)
            
            self.optimizer.zero_grad()
            outputs = self.model(X_batch)
            loss = self.criterion(outputs, y_batch)
            loss.backward()
            self.optimizer.step()
            
            total_loss += loss.item()
            
        return total_loss / len(dataloader)
        
    def evaluate(self, dataloader: DataLoader) -> Tuple[float, float]:
        """Evaluate model"""
        self.model.eval()
        total_loss = 0
        correct = 0
        total = 0
        
        with torch.no_grad():
            for X_batch, y_batch in dataloader:
                X_batch = X_batch.to(self.device)
                y_batch = y_batch.to(self.device)
                
                outputs = self.model(X_batch)
                loss = self.criterion(outputs, y_batch)
                total_loss += loss.item()
                
                _, predicted = torch.max(outputs, 1)
                total += y_batch.size(0)
                correct += (predicted == y_batch).sum().item()
                
        avg_loss = total_loss / len(dataloader)
        accuracy = correct / total
        return avg_loss, accuracy
        
    def train(
        self,
        train_loader: DataLoader,
        val_loader: DataLoader,
        epochs: int = 100,
        patience: int = 10,
        verbose: bool = True
    ) -> dict:
        """
        Full training loop with early stopping
        
        Returns:
            Training history dict
        """
        patience_counter = 0
        
        for epoch in range(epochs):
            train_loss = self.train_epoch(train_loader)
            val_loss, val_acc = self.evaluate(val_loader)
            
            self.train_losses.append(train_loss)
            self.val_losses.append(val_loss)
            
            # Early stopping check
            if val_loss < self.best_val_loss:
                self.best_val_loss = val_loss
                self.best_model_state = self.model.state_dict().copy()
                patience_counter = 0
            else:
                patience_counter += 1
                
            if verbose and (epoch + 1) % 10 == 0:
                print(f"Epoch {epoch+1}/{epochs} - Train Loss: {train_loss:.4f}, "
                      f"Val Loss: {val_loss:.4f}, Val Acc: {val_acc:.4f}")
                
            if patience_counter >= patience:
                print(f"Early stopping at epoch {epoch+1}")
                break
                
        # Restore best model
        if self.best_model_state:
            self.model.load_state_dict(self.best_model_state)
            
        # Final evaluation
        _, final_acc = self.evaluate(val_loader)
        
        return {
            "train_losses": self.train_losses,
            "val_losses": self.val_losses,
            "best_val_loss": self.best_val_loss,
            "final_accuracy": final_acc,
            "epochs_trained": len(self.train_losses)
        }


def walk_forward_analysis(
    X: np.ndarray,
    y: np.ndarray,
    model_class: type = DirectionLSTM,
    n_splits: int = 10,
    train_ratio: float = 0.8,
    config: dict = None
) -> Tuple[List[float], float]:
    """
    Walk-Forward Analysis for robust model validation
    
    Args:
        X: Full feature array
        y: Full label array
        model_class: Model class to use
        n_splits: Number of walk-forward windows
        train_ratio: Ratio of training data in each window
        config: Model configuration dict
        
    Returns:
        accuracies: List of accuracies for each window
        wfe: Walk-Forward Efficiency
    """
    if config is None:
        config = {
            "input_size": X.shape[2],
            "hidden_size": DIRECTION_CONFIG.hidden_size,
            "num_layers": DIRECTION_CONFIG.num_layers,
            "dropout": DIRECTION_CONFIG.dropout,
            "output_size": DIRECTION_CONFIG.output_size
        }
    
    window_size = len(X) // n_splits
    accuracies = []
    
    print(f"\nWalk-Forward Analysis with {n_splits} windows...")
    
    for i in range(n_splits - 1):
        # Define window boundaries
        start_idx = i * window_size
        end_idx = (i + 2) * window_size
        
        if end_idx > len(X):
            break
            
        # Split into train/test
        window_X = X[start_idx:end_idx]
        window_y = y[start_idx:end_idx]
        
        split_idx = int(len(window_X) * train_ratio)
        X_train, X_test = window_X[:split_idx], window_X[split_idx:]
        y_train, y_test = window_y[:split_idx], window_y[split_idx:]
        
        # Create dataloaders
        train_dataset = TensorDataset(
            torch.FloatTensor(X_train),
            torch.LongTensor(y_train)
        )
        test_dataset = TensorDataset(
            torch.FloatTensor(X_test),
            torch.LongTensor(y_test)
        )
        
        train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)
        test_loader = DataLoader(test_dataset, batch_size=64)
        
        # Train model
        model = model_class(**config)
        trainer = ModelTrainer(model, learning_rate=1e-4)
        trainer.train(train_loader, test_loader, epochs=50, patience=5, verbose=False)
        
        # Evaluate on test set
        _, accuracy = trainer.evaluate(test_loader)
        accuracies.append(accuracy)
        
        print(f"Window {i+1}: Accuracy = {accuracy:.4f}")
    
    # Calculate Walk-Forward Efficiency
    mean_accuracy = np.mean(accuracies)
    std_accuracy = np.std(accuracies)
    wfe = mean_accuracy - std_accuracy  # Penalize inconsistency
    
    print(f"\nWFA Results:")
    print(f"Mean Accuracy: {mean_accuracy:.4f} (+/- {std_accuracy:.4f})")
    print(f"Walk-Forward Efficiency: {wfe:.4f}")
    
    return accuracies, wfe


def train_direction_model(
    X_train: np.ndarray,
    y_train: np.ndarray,
    X_val: np.ndarray,
    y_val: np.ndarray,
    model_type: str = "lstm"
) -> Tuple[nn.Module, dict]:
    """
    Train direction prediction model
    
    Args:
        X_train: Training features (samples, seq_len, features)
        y_train: Training labels
        X_val: Validation features
        y_val: Validation labels
        model_type: "lstm" or "gru"
        
    Returns:
        model: Trained model
        history: Training history
    """
    # Model configuration
    input_size = X_train.shape[2]
    config = {
        "input_size": input_size,
        "hidden_size": DIRECTION_CONFIG.hidden_size,
        "num_layers": DIRECTION_CONFIG.num_layers,
        "dropout": DIRECTION_CONFIG.dropout,
        "output_size": DIRECTION_CONFIG.output_size
    }
    
    # Create model
    if model_type == "gru":
        model = DirectionGRU(**config)
    else:
        model = DirectionLSTM(**config)
    
    print(f"Training {model_type.upper()} model...")
    print(f"Input shape: {X_train.shape}")
    print(f"Model config: {config}")
    
    # Create dataloaders
    train_dataset = TensorDataset(
        torch.FloatTensor(X_train),
        torch.LongTensor(y_train)
    )
    val_dataset = TensorDataset(
        torch.FloatTensor(X_val),
        torch.LongTensor(y_val)
    )
    
    train_loader = DataLoader(
        train_dataset,
        batch_size=TRAINING_CONFIG.batch_size,
        shuffle=True
    )
    val_loader = DataLoader(
        val_dataset,
        batch_size=TRAINING_CONFIG.batch_size
    )
    
    # Train
    trainer = ModelTrainer(model, learning_rate=TRAINING_CONFIG.learning_rate)
    history = trainer.train(
        train_loader,
        val_loader,
        epochs=TRAINING_CONFIG.epochs,
        patience=TRAINING_CONFIG.early_stopping_patience
    )
    
    print(f"\nTraining complete!")
    print(f"Final validation accuracy: {history['final_accuracy']:.4f}")
    
    return model, history


def save_model(model: nn.Module, history: dict, name: str = "direction_model"):
    """Save model and training history"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Save PyTorch model
    model_path = MODELS_DIR / f"{name}_{timestamp}.pt"
    torch.save({
        'model_state_dict': model.state_dict(),
        'history': history
    }, model_path)
    print(f"Model saved to {model_path}")
    
    # Save history
    history_path = MODELS_DIR / f"{name}_{timestamp}_history.json"
    with open(history_path, 'w') as f:
        json.dump({
            "train_losses": history["train_losses"],
            "val_losses": history["val_losses"],
            "best_val_loss": history["best_val_loss"],
            "final_accuracy": history["final_accuracy"],
            "epochs_trained": history["epochs_trained"]
        }, f, indent=2)
    print(f"History saved to {history_path}")
    
    return model_path


if __name__ == "__main__":
    # Example: Train on synthetic data
    print("Creating synthetic data for testing...")
    
    # Synthetic data
    n_samples = 10000
    seq_len = 100
    n_features = 15
    
    X = np.random.randn(n_samples, seq_len, n_features).astype(np.float32)
    y = np.random.randint(0, 2, n_samples)
    
    # Split
    split = int(0.8 * n_samples)
    X_train, X_val = X[:split], X[split:]
    y_train, y_val = y[:split], y[split:]
    
    # Train
    model, history = train_direction_model(X_train, y_train, X_val, y_val, model_type="lstm")
    
    # Walk-forward analysis
    accuracies, wfe = walk_forward_analysis(X, y, n_splits=5)
    
    # Save
    save_model(model, history)
