import asyncio
import os
import sys
from telethon import TelegramClient

API_ID = 21406232
API_HASH = "8731242b0a5282828af2c8e2572a0a6d"
BOT_TOKEN = os.environ.get("BOT_TOKEN")
CHAT_ID = os.environ.get("CHAT_ID")

def check_environ():
    global CHAT_ID, BOT_TOKEN
    if not BOT_TOKEN:
        print("[-] Invalid BOT_TOKEN")
        exit(1)
    if not CHAT_ID:
        print("[-] Invalid CHAT_ID")
        exit(1)
    else:
        try:
            CHAT_ID = int(CHAT_ID)
        except ValueError:
            print("[-] CHAT_ID must be an integer")
            exit(1)

async def main():
    print("[+] Uploading to telegram")
    check_environ()
    
    files = sys.argv[1:]
    print("[+] Files:", files)
    
    if not files:
        print("[-] No files to upload")
        exit(1)
    
    # 获取描述信息（从环境变量）
    caption = os.environ.get("DESCRIPTION", "🧩 Kernel build report")
    print("[+] Caption:", caption)
    
    print("[+] Logging in Telegram with bot")
    script_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
    session_dir = os.path.join(script_dir, "tgbot.session")
    
    async with await TelegramClient(
        session=session_dir,
        api_id=API_ID,
        api_hash=API_HASH
    ).start(bot_token=BOT_TOKEN) as bot:
        
        print("[+] Sending")
        await bot.send_file(
            entity=CHAT_ID,
            file=files,
            caption=caption,
            parse_mode="html",
            silent=False
        )
        
        print("[+] Done!")
        exit(0)

if __name__ == "__main__":
    try:
        asyncio.set_event_loop(asyncio.new_event_loop())
        asyncio.get_event_loop().run_until_complete(main())
        exit(0)
    except Exception as e:
        print(f"[-] An error occurred: {e}")
        exit(1)
