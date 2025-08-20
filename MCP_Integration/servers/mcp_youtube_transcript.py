#!/usr/bin/env python3
"""
YouTube Transcript MCP Server
Extract and process transcripts from YouTube videos for trading education and analysis.
"""

import asyncio
import json
import logging
import re
from typing import Any, Dict, List, Optional
from urllib.parse import parse_qs, urlparse

from mcp.server import Server
from mcp.server.models import InitializationOptions
from mcp.server.stdio import stdio_server
from mcp.types import (
    Resource,
    Tool,
    TextContent,
    ImageContent,
    EmbeddedResource,
    LoggingLevel,
    ServerCapabilities
)
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api.formatters import TextFormatter

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class YouTubeTranscriptServer:
    def __init__(self):
        self.server = Server("youtube-transcript")
        self.setup_handlers()
    
    def setup_handlers(self):
        @self.server.list_resources()
        async def handle_list_resources() -> List[Resource]:
            """List available resources."""
            return [
                Resource(
                    uri="youtube://transcripts",
                    name="YouTube Transcripts",
                    description="Extract transcripts from YouTube videos",
                    mimeType="text/plain"
                )
            ]
        
        @self.server.read_resource()
        async def handle_read_resource(uri: str) -> str:
            """Read a specific resource."""
            if uri == "youtube://transcripts":
                return "YouTube Transcript extraction service ready."
            else:
                raise ValueError(f"Unknown resource: {uri}")
        
        @self.server.list_tools()
        async def handle_list_tools() -> List[Tool]:
            """List available tools."""
            return [
                Tool(
                    name="get_transcripts",
                    description="Extract and process transcripts from a YouTube video.\n\n**Parameters:**\n- `url` (string, required): YouTube video URL or ID.\n- `lang` (string, optional, default 'en'): Language code for transcripts (e.g. 'en', 'uk', 'ja', 'ru', 'zh').\n- `enableParagraphs` (boolean, optional, default false): Enable automatic paragraph breaks.\n\n**IMPORTANT:** If the user does *not* specify a language *code*, **DO NOT** include the `lang` parameter in the tool call. Do not guess the language or use parts of the user query as the language code.",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "url": {
                                "type": "string",
                                "description": "YouTube video URL or ID"
                            },
                            "lang": {
                                "type": "string",
                                "default": "en",
                                "description": "Language code for transcripts, default 'en' (e.g. 'en', 'uk', 'ja', 'ru', 'zh')"
                            },
                            "enableParagraphs": {
                                "type": "boolean",
                                "default": False,
                                "description": "Enable automatic paragraph breaks, default `false`"
                            }
                        },
                        "required": ["url"],
                        "additionalProperties": False
                    }
                )
            ]
        
        @self.server.call_tool()
        async def handle_call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
            """Handle tool calls."""
            if name == "get_transcripts":
                return await self.get_transcripts(**arguments)
            else:
                raise ValueError(f"Unknown tool: {name}")
    
    def extract_video_id(self, url: str) -> str:
        """Extract video ID from YouTube URL or return the ID if already provided."""
        # If it's already a video ID (11 characters, alphanumeric)
        if re.match(r'^[a-zA-Z0-9_-]{11}$', url):
            return url
        
        # Parse various YouTube URL formats
        patterns = [
            r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
            r'youtube\.com/v/([a-zA-Z0-9_-]{11})',
            r'youtube\.com/watch\?.*v=([a-zA-Z0-9_-]{11})'
        ]
        
        for pattern in patterns:
            match = re.search(pattern, url)
            if match:
                return match.group(1)
        
        raise ValueError(f"Could not extract video ID from URL: {url}")
    
    def format_transcript_with_paragraphs(self, transcript_list: List[Dict], enable_paragraphs: bool = False) -> str:
        """Format transcript with optional paragraph breaks."""
        if not transcript_list:
            return "No transcript available."
        
        formatter = TextFormatter()
        text = formatter.format_transcript(transcript_list)
        
        if enable_paragraphs:
            # Add paragraph breaks based on longer pauses or sentence endings
            sentences = text.split('. ')
            paragraphs = []
            current_paragraph = []
            
            for sentence in sentences:
                current_paragraph.append(sentence)
                # Create paragraph break every 3-4 sentences or at natural breaks
                if len(current_paragraph) >= 3 or sentence.endswith('?') or sentence.endswith('!'):
                    paragraphs.append('. '.join(current_paragraph) + '.')
                    current_paragraph = []
            
            # Add any remaining sentences
            if current_paragraph:
                paragraphs.append('. '.join(current_paragraph))
            
            return '\n\n'.join(paragraphs)
        
        return text
    
    async def get_transcripts(self, url: str, lang: str = "en", enableParagraphs: bool = False) -> List[TextContent]:
        """Extract transcripts from YouTube video."""
        try:
            video_id = self.extract_video_id(url)
            logger.info(f"Extracting transcript for video ID: {video_id}")
            
            # Get available transcripts
            transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)
            
            # Try to get transcript in requested language
            transcript = None
            available_languages = []
            
            for t in transcript_list:
                available_languages.append(t.language_code)
                if t.language_code == lang:
                    transcript = t
                    break
            
            # If requested language not found, try English as fallback
            if transcript is None and lang != "en":
                for t in transcript_list:
                    if t.language_code == "en":
                        transcript = t
                        logger.info(f"Language '{lang}' not available, using English instead")
                        break
            
            # If still no transcript, get the first available
            if transcript is None:
                transcript = next(iter(transcript_list))
                logger.info(f"Using first available language: {transcript.language_code}")
            
            # Fetch the transcript
            transcript_data = transcript.fetch()
            
            # Format the transcript
            formatted_text = self.format_transcript_with_paragraphs(transcript_data, enableParagraphs)
            
            # Prepare metadata
            metadata = {
                "video_id": video_id,
                "language": transcript.language_code,
                "is_generated": transcript.is_generated,
                "available_languages": available_languages,
                "total_entries": len(transcript_data),
                "paragraphs_enabled": enableParagraphs
            }
            
            result = f"**YouTube Transcript Extraction**\n\n"
            result += f"**Video ID:** {video_id}\n"
            result += f"**Language:** {transcript.language_code}\n"
            result += f"**Type:** {'Auto-generated' if transcript.is_generated else 'Manual'}\n"
            result += f"**Available Languages:** {', '.join(available_languages)}\n"
            result += f"**Total Entries:** {len(transcript_data)}\n\n"
            result += f"**Transcript:**\n\n{formatted_text}\n\n"
            result += f"**Metadata:** {json.dumps(metadata, indent=2)}"
            
            return [TextContent(type="text", text=result)]
            
        except Exception as e:
            error_msg = f"Error extracting transcript: {str(e)}"
            logger.error(error_msg)
            return [TextContent(type="text", text=error_msg)]

async def main():
    """Main entry point for the server."""
    server_instance = YouTubeTranscriptServer()
    
    async with stdio_server() as (read_stream, write_stream):
        await server_instance.server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="youtube-transcript",
                server_version="1.0.0",
                capabilities=ServerCapabilities(
                    logging={},
                    prompts={},
                    resources={},
                    tools={}
                )
            )
        )

if __name__ == "__main__":
    asyncio.run(main())