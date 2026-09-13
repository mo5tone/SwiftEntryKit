#!/usr/bin/env python3
"""Generate a self-contained HTML coverage report from an .xcresult bundle.

Usage: python3 generate-coverage-report.py <path.xcresult> [output.html]
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
    if executable == 0:
        return 0.0
    return 100.0 * covered / executable


def color(ratio):
    if ratio >= 80:
        return "#2ecc71"
    if ratio >= 50:
        return "#f1c40f"
    return "#e74c3c"


def file_row(name, covered, executable):
    ratio = pct(covered, executable)
    return (
        f"<tr>"
        f"<td class='name'>{html.escape(name)}</td>"
        f"<td class='num'>{covered}/{executable}</td>"
        f"<td><div class='bar'><div class='fill' style='width:{ratio:.1f}%;background:{color(ratio)}'></div></div></td>"
        f"<td class='num'>{ratio:.1f}%</td>"
        f"</tr>"
    )


def build_report(data, result_bundle):
    overall = pct(data.get("coveredLines", 0), data.get("executableLines", 0))
    rows = []
    for target in data.get("targets", []):
        for f in sorted(
            target.get("files", []),
            key=lambda f: pct(f.get("coveredLines", 0), f.get("executableLines", 0)),
        ):
            path = f.get("path") or f.get("name", "unknown")
            name = path.split("/Source/SwiftEntryKit/")[-1] if "/Source/" in path else path
            rows.append(file_row(name, f.get("coveredLines", 0), f.get("executableLines", 0)))
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
  <div class="meta">{data.get('coveredLines', 0)} / {data.get('executableLines', 0)} lines · {result_bundle}</div>
  <table>
    <thead><tr><th>File</th><th>Lines</th><th></th><th>Coverage</th></tr></thead>
    <tbody>
      {''.join(rows)}
    </tbody>
  </table>
</body>
</html>
"""


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    result_bundle = os.path.abspath(sys.argv[1])
    output = sys.argv[2] if len(sys.argv) > 2 else "coverage.html"
    data = json.loads(run_xccov(result_bundle))
    with open(output, "w") as fh:
        fh.write(build_report(data, result_bundle))
    print(f"Wrote {output}")


if __name__ == "__main__":
    main()
