import logging
from logging.handlers import RotatingFileHandler
from pathlib import Path

class KalenLogger:

    def __init__(self, log_dir="logs"):

        Path(log_dir).mkdir(exist_ok=True)

        self.logger = logging.getLogger("KALEN")

        self.logger.setLevel(logging.INFO)

        if not self.logger.handlers:

            handler = RotatingFileHandler(
                f"{log_dir}/kalen.log",
                maxBytes=5*1024*1024,
                backupCount=5
            )

            formatter = logging.Formatter(
                "%(asctime)s | %(levelname)s | %(module)s | %(message)s"
            )

            handler.setFormatter(formatter)

            self.logger.addHandler(handler)

    def info(self, message):
        self.logger.info(message)

    def warning(self, message):
        self.logger.warning(message)

    def error(self, message):
        self.logger.error(message)

    def critical(self, message):
        self.logger.critical(message)

    def exception(self, message):
        self.logger.exception(message)