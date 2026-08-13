def render_stats(stats: dict) -> str:
    total = stats.get("total", 0)
    kinds = stats.get("kinds") or {}
    lines = [f"Total events: {total}"]
    for k, v in sorted(kinds.items()):
        lines.append(f"{k}: {v}")
    text = "\n".join(lines)
    try:
        import streamlit as st
        st.write(text)
    except Exception:
        print(text)
    return text

def render_stats_copy(stats: dict) -> str:
    total = stats.get("total", 0)
    kinds = stats.get("kinds") or {}
    lines = [f"Total events: {total}"]
    for k, v in sorted(kinds.items()):
        lines.append(f"{k}: {v}")
    return "\n".join(lines)
