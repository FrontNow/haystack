from typing import Optional, List

import json

from fastapi import FastAPI, APIRouter, Form, HTTPException, Depends
from pydantic import BaseModel
from haystack import Pipeline
from haystack.nodes import PreProcessor

from rest_api.utils import get_app, get_pipelines
from rest_api.config import FILE_UPLOAD_PATH
from rest_api.controller.utils import as_form

router = APIRouter()
app: FastAPI = get_app()
crawling_pipeline: Pipeline = get_pipelines().get("crawling_pipeline", None)


@as_form
class PreprocessorParams(BaseModel):
    clean_whitespace: Optional[bool] = None
    clean_empty_lines: Optional[bool] = None
    clean_header_footer: Optional[bool] = None
    split_by: Optional[str] = None
    split_length: Optional[int] = None
    split_overlap: Optional[int] = None
    split_respect_sentence_boundary: Optional[bool] = None


class Response(BaseModel):
    file_id: str


@router.post("/crawl")
def crawl(
        urls: List[str],
        # JSON serialized string
        meta: Optional[str] = Form("null"),  # type: ignore
        preprocessor_params: PreprocessorParams = Depends(PreprocessorParams.as_form),  # type: ignore
):
    """
    You can use this endpoint to crawl urls for indexing
    """
    if not crawling_pipeline:
        raise HTTPException(status_code=501, detail="Crawling Pipeline is not configured.")

    # Find nodes names
    preprocessors = crawling_pipeline.get_nodes_by_class(PreProcessor)

    meta_form = json.loads(meta) or {}  # type: ignore
    if not isinstance(meta_form, dict):
        raise HTTPException(status_code=500, detail=f"The meta field must be a dict or None, not {type(meta_form)}")

    params = {}
    for preprocessor in preprocessors:
        params[preprocessor.name] = preprocessor_params.dict()
    params['Crawler'] = {'urls': urls, 'return_documents': True, 'output_dir': FILE_UPLOAD_PATH}

    crawling_pipeline.run(params=params, meta=meta_form)
