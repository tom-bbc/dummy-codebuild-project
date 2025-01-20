import logging

from package.methods import method

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

time = method()
logger.info(f"Time: {time}")
