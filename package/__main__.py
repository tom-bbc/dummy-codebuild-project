import logging

from package.invoketime import invoke_time

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

time = invoke_time()
logger.info(f"Time: {time}")
