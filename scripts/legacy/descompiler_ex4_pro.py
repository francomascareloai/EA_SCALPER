# descompiler_ex4_pro.py
import struct
import sys
import re
from capstone import Cs, CS_ARCH_X86, CS_MODE_32
from typing import Dict, List, Tuple

# Configura o Capstone Disassembler
md = Cs(CS_ARCH_X86, CS_MODE_32)

# Assinaturas conhecidas de funções MQL4 (OnTick, OnInit, etc.)
MQL4_SIGNATURES = {
    b"OnTick": "void OnTick()",
    b"OnInit": "int OnInit()",
    b"OnDeinit": "void OnDeinit()",
    b"start": "int start()",
    b"init": "int init()",
    b"deinit": "int deinit()"
}

# Mapeamento de opcodes comuns para operações MQL4
OPCODE_MAP = {
    0x55: "PUSH EBP",
    0x89: "MOV EBP, ESP",
    0x83: "SUB ESP, xx",
    0xC9: "LEAVE",
    0xC3: "RETN"
}

def read_file_raw(path: str) -> bytes:
    with open(path, 'rb') as f:
        return f.read()

def detect_section_code(data: bytes) -> int:
    # Procura por região com padrão de código (x86)
    for i in range(0, len(data) - 4):
        if data[i:i+4] == b'\x55\x89\xE5':  # PUSH EBP + MOV EBP, ESP
            return i
    return -1

def disassemble_code_section(data: bytes, start: int, size: int = 2048) -> List[Tuple[int, str, str]]:
    code = data[start:start+size]
    disasm = []
    for i in md.disasm(code, 0x08048000):  # Endereço base fictício
        disasm.append((i.address, i.mnemonic, i.op_str))
    return disasm

def extract_function_names(data: bytes) -> List[str]:
    strings = []
    current = ""
    for b in data:
        if 32 <= b <= 126:
            current += chr(b)
        else:
            if len(current) >= 4 and current.isalnum():
                strings.append(current)
            current = ""
    # Filtra apenas as que parecem funções MQL
    return [s for s in strings if any(key in s.encode() for key in MQL4_SIGNATURES.keys())]

def reconstruct_mql4_skeleton(disasm_lines: List[Tuple], functions: List[str]) -> str:
    code = "// Código reconstruído heuristicamente - NÃO É ORIGINAL\n"
    code += "#property strict\n\n"
    
    for func in functions:
        real_name = MQL4_SIGNATURES.get(func.encode(), func)
        code += f"{real_name} {{\n"
        code += "   // Código descompilado parcialmente\n"
        for addr, mnem, op in disasm_lines:
            if "CALL" in mnem and "0x" in op:
                code += f"   // Provável chamada de função: {mnem} {op}\n"
            elif "MOV" in mnem and "EAX" in op:
                code += f"   // Operação de retorno ou variável\n"
        code += "   return(0);\n}}\n\n"
    return code

def find_import_table(data: bytes) -> List[str]:
    # Procura por chamadas a funções da biblioteca MQL (ex: OrderSend, iClose, etc)
    import_candidates = []
    known_calls = [
        b"OrderSend", b"OrderClose", b"iClose", b"iOpen", b"MarketInfo",
        b"ObjectCreate", b"ObjectSet", b"PlaySound", b"AccountBalance"
    ]
    for call in known_calls:
        if call in data:
            import_candidates.append(call.decode())
    return import_candidates

def main():
    if len(sys.argv) != 2:
        print("Uso: python descompiler_ex4_pro.py <arquivo.ex4>")
        return
    
    path = sys.argv[1]
    print(f"[+] Carregando arquivo: {path}")
    data = read_file_raw(path)
    
    print("[+] Detectando seção de código...")
    code_start = detect_section_code(data)
    if code_start == -1:
        print("[-] Não foi possível localizar código executável.")
        return
    
    print(f"[+] Seção de código encontrada em offset: {hex(code_start)}")
    disasm = disassemble_code_section(data, code_start, 4096)
    
    print("[+] Extraindo nomes de funções...")
    funcs = extract_function_names(data)
    
    print("[+] Reconstruindo estrutura MQL4...")
    skeleton = reconstruct_mql4_skeleton(disasm, funcs)
    
    print("[+] Procurando chamadas a funções MQL...")
    imports = find_import_table(data)
    if imports:
        print("[+] Funções MQL detectadas:")
        for imp in imports:
            print(f"    {imp}")
    
    # Salva o resultado
    output = "reconstructed_source.mq4"
    with open(output, 'w') as f:
        f.write(f"// Gerado por EX4-Decompiler Pro\n// Funções detectadas: {', '.join(funcs)}\n")
        f.write(f"// Chamadas externas: {', '.join(imports)}\n\n")
        f.write(skeleton)
    
    print(f"[+] Código reconstruído salvo em: {output}")

if __name__ == "__main__":
    main()