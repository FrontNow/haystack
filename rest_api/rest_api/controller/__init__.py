# this import is required for the Custom Components to be registered
from rest_api.pipeline import custom_component

import logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.info("Loading custom component")
