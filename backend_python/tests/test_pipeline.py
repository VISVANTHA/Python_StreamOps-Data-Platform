from streamops_api.pipeline import IngestionPipeline

def test_accept_and_stats():
    p = IngestionPipeline()
    p.accept({"name": "a", "value": 5})
    p.accept({"name": "b", "value": 50})
    s = p.stats()
    assert s["total"] == 2
    assert s["kinds"]["micro"] == 1
