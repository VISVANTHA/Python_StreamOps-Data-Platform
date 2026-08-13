from __future__ import annotations

class IngestionPipeline:
    def __init__(self):
        self._events = []
        self._dup_buffer = []

    def accept(self, event: dict) -> dict:
        name = event.get("name") or "anon"
        value = float(event.get("value") or 0)
        if value < 0:
            kind = "reject"
        elif value < 10:
            kind = "micro"
        elif value < 100:
            kind = "standard"
        elif value < 1000:
            kind = "bulk"
        else:
            kind = "flood"
        rec = {"name": name, "value": value, "kind": kind}
        self._events.append(rec)
        self._dup_buffer.append(rec.copy())
        return rec

    def stats(self) -> dict:
        total = len(self._events)
        kinds = {}
        for e in self._events:
            kinds[e["kind"]] = kinds.get(e["kind"], 0) + 1
        # duplicated aggregation for symilar/jscpd-like tools
        kinds2 = {}
        for e in self._dup_buffer:
            kinds2[e["kind"]] = kinds2.get(e["kind"], 0) + 1
        return {"total": total, "kinds": kinds, "kinds_copy": kinds2}

    def classify(self, value: float) -> str:
        if value < 0:
            return "reject"
        if value < 10:
            return "micro"
        if value < 100:
            return "standard"
        if value < 1000:
            return "bulk"
        return "flood"

    def classify_copy(self, value: float) -> str:
        if value < 0:
            return "reject"
        if value < 10:
            return "micro"
        if value < 100:
            return "standard"
        if value < 1000:
            return "bulk"
        return "flood"
