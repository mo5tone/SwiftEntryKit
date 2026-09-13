#!/usr/bin/env python3
"""Render an .xcresult bundle as a self-contained HTML report.

Prints a Markdown summary to stdout (for GitHub step summaries) and writes the
HTML report to a file.

Usage: python3 generate-coverage-report.py <path.xcresult> <output.html>
"""

import html
import json
import os
import subprocess
import sys


def run_xccov(result_bundle):
    return subprocess.run(
        ["xcrun", "xccov", "view", "--report", "--json", result_bundle],
        check=True,
        capture_output=True,
        text=True,
    ).stdout


def pct(covered, executable):
    return 0.0 if executable == 0 else 100.0 * covered / executable


def color(ratio):
    if ratio >= 80:
        return "#2ecc71"
    if ratio >= 50:
        return "#f1c40f"
    return "#e74c3c"


def short_name(path):
    marker = "/Source/SwiftEntryKit/"
    return path.split(marker)[-1] if marker in path else path


def library_targets(data):
    """Only report the library targets, skipping *Tests targets (which re-list
    the library sources via the test host, double-counting them)."""
    return [t for t in data.get("targets", []) if not t.get("name", "").endswith("Tests")]


def totals(targets):
    covered = sum(t.get("coveredLines", 0) for t in targets)
    executable = sum(t.get("executableLines", 0) for t in targets)
    return covered, executable


def file_rows(targets):
    rows = []
    for target in targets:
        for f in target.get("files", []):
            covered = f.get("coveredLines", 0)
            executable = f.get("executableLines", 0)
            ratio = pct(covered, executable)
            rows.append((ratio, short_name(f.get("path") or f.get("name", "?")), covered, executable))
    return sorted(rows)


def build_html(targets, covered, executable):
    overall = pct(covered, executable)
    body = "".join(
        f"<tr>"
        f"<td class='name'>{html.escape(name)}</td>"
        f"<td class='num'>{c}/{e}</td>"
        f"<td><div class='bar'><div class='fill' style='width:{ratio:.1f}%;background:{color(ratio)}'></div></div></td>"
        f"<td class='num'>{ratio:.1f}%</td>"
        f"</tr>"
        for ratio, name, c, e in file_rows(targets)
    )
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>SwiftEntryKit Coverage</title>
<style>
  body {{ font-family: -apple-system, sans-serif; margin: 2rem; color: #222; }}
  h1 {{ font-size: 1.4rem; }}
  .overall {{ font-size: 2.4rem; font-weight: 700; color: {color(overall)}; }}
  table {{ border-collapse: collapse; width: 100%; margin-top: 1rem; }}
  th, td {{ padding: .4rem .6rem; border-bottom: 1px solid #eee; text-align: left; }}
  td.name {{ font-family: ui-monospace, monospace; font-size: .85rem; }}
  td.num {{ text-align: right; white-space: nowrap; }}
  .bar {{ width: 12rem; height: .6rem; background: #eee; border-radius: .3rem; overflow: hidden; }}
  .fill {{ height: 100%; }}
  .meta {{ color: #888; font-size: .8rem; }}
</style>
</head>
<body>
  <h1>SwiftEntryKit — Code Coverage</h1>
  <div class="overall">{overall:.1f}%</div>
  <div class="meta">{covered} / {executable} lines</div>
  <table>
    <thead><tr><th>File</th><th>Lines</th><th></th><th>Coverage</th></tr></thead>
    <tbody>
      {body}
    </tbody>
  </table>
</body>
</html>
"""


def build_markdown(targets, covered, executable):
    overall = pct(covered, executable)
    lines = [f"## Code Coverage", f"", f"**{overall:.1f}%** ({covered}/{executable} lines)", ""]
    lines += ["| Coverage | File | Lines |", "| --- | --- | --- |"]
    for ratio, name, c, e in file_rows(targets):
        lines.append(f"| {ratio:.1f}% | `{name}` | {c}/{e} |")
    return "\n".join(lines)


def main():
    if len(sys.argv) < 3:
        print(__doc__, file=sys.stderr)
        sys.exit(1)
    result_bundle = os.path.abspath(sys.argv[1])
    output = sys.argv[2]
    data = json.loads(run_xccov(result_bundle))
    targets = library_targets(data)
    covered, executable = totals(targets)
    with open(output, "w") as fh:
        fh.write(build_html(targets, covered, executable))
    print(build_markdown(targets, covered, executable))
    print(f"Wrote {output}", file=sys.stderr)


if __name__ == "__main__":
    main()
