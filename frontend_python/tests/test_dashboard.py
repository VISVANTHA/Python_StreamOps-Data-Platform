from streamops_ui.dashboard import render_stats_copy

def test_render():
    out = render_stats_copy({"total": 2, "kinds": {"micro": 1, "standard": 1}})
    assert "Total events: 2" in out
