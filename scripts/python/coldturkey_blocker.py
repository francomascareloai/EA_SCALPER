"""
Get Pro Subscription of Cold Turkey Blocker.

Author: Anshul Raj Verma
Github: https://github.com/arv-anshul

Check Also
----------
`ColdTurkeyBlocker-Disable`: Disable all blocker at once.
https://github.com/arv-anshul/ColdTurkeyBlocker-Disable
"""

import json
import logging
import os
import sqlite3
import typing
from pathlib import Path

MAC_DB_PATH = Path("/Library/Application Support/Cold Turkey/data-app.db")
WIN_DB_PATH = Path("C:/ProgramData/Cold Turkey/data-app.db")
SystemType = typing.Literal["mac", "win"]

logging.basicConfig(level=logging.INFO, format="%(levelname)s -> %(message)s")


def configure_db_path(system_type: SystemType) -> Path:
    db_path = MAC_DB_PATH if system_type == "mac" else WIN_DB_PATH
    if not db_path.exists():
        logging.info(f"{db_path = !s}")
        logging.error("Database does not exists.")
        exit(1)
    return db_path


def kill_blocker(system_type: SystemType):
    if system_type == "mac":
        kill_blocker_command = "/usr/bin/killall 'Cold Turkey Blocker'"
        os.system(kill_blocker_command)  # noqa: S605
        logging.critical("Open Blocker App")
    else:
        logging.critical('"Reopen Blocker" OR "Restart the system"')


def upgrade_blocker(c: sqlite3.Cursor) -> None:
    s = c.execute("SELECT value FROM settings WHERE key = 'settings'").fetchone()[0]
    data = json.loads(s)

    blocker_status = data["additional"]["proStatus"]
    logging.info(f"Blocker status is {blocker_status!r}")

    if blocker_status == "pro":
        logging.info("Changing status to 'free'.")
        data["additional"]["proStatus"] = "free"
    elif blocker_status == "free":
        logging.info("Changing status to 'pro'.")
        data["additional"]["proStatus"] = "pro"

    c.execute(
        "UPDATE settings SET value = ? WHERE key = 'settings'",
        (json.dumps(data),),
    )


def main():
    while True:
        system_type: SystemType = input("Choose [mac|win]: ")  # type: ignore
        if system_type.lower() in ["mac", "win"]:
            break
        logging.warning("Choose either ``mac`` or ``win``")

    # FIXME: If you get error in windows system.
    # Please fix the error and create pull request.
    if system_type == "win":
        logging.warning("Code is not tested for Windows.")

    db_path = configure_db_path(system_type)
    try:
        with sqlite3.connect(db_path) as conn:
            c = conn.cursor()
            upgrade_blocker(c)
            logging.info("Committing changed settings into database.")
            conn.commit()
            kill_blocker(system_type)
    except sqlite3.Error:
        logging.error("Failed to Connect with Cold Turkey blocker.")
        raise


if __name__ == "__main__":
    main()
