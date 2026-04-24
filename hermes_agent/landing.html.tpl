<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Hermes Agent</title>
  <style>
    body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,Cantarell,Noto Sans,sans-serif;margin:0;padding:16px;background:#0b0f14;color:#e6edf3}
    a{font:inherit}
    .card{max-width:1100px;margin:0 auto;background:#111827;border:1px solid #1f2937;border-radius:8px;padding:16px}
    .row{display:flex;gap:10px;flex-wrap:wrap;align-items:center}
    .btn{background:#2563eb;color:#fff;border:0;border-radius:8px;padding:10px 14px;text-decoration:none;display:inline-block;font-size:14px}
    .btn.secondary{background:#334155}
    .btn:hover{filter:brightness(1.12)}
    .muted{color:#9ca3af;font-size:14px}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:10px;margin:12px 0}
    .item{padding:10px 12px;border-radius:8px;background:#0d1117;border:1px solid #1f2937;font-size:14px}
    .term{margin-top:14px;height:58vh;min-height:360px;border:1px solid #1f2937;border-radius:8px;overflow:hidden}
    iframe{width:100%;height:100%;border:0;background:#000}
    code{background:#0b1220;padding:2px 6px;border-radius:6px}
  </style>
</head>
<body>
  <div class="card">
    <h2 style="margin:0 0 4px">Hermes Agent</h2>
    <p class="muted" style="margin:0 0 12px">Home Assistant add-on wrapper for Nous Research Hermes Agent.</p>

    <div class="grid">
      <div class="item">Gateway: running through add-on logs</div>
      <div class="item">Dashboard: __ENABLE_DASHBOARD__</div>
      <div class="item">Terminal: __ENABLE_TERMINAL__</div>
      <div class="item">Disk: __DISK_USED__ / __DISK_TOTAL__ (__DISK_PCT__), __DISK_AVAIL__ free</div>
    </div>

    <div class="row">
      <a class="btn" href="./dashboard/" target="_self">Open Hermes Dashboard</a>
      <a class="btn secondary" href="./terminal/" target="_self">Open Terminal</a>
    </div>

    <p class="muted">
      Hermes configuration is generated from add-on options into <code>/config/.hermes</code>.
      Use the terminal for advanced Hermes CLI commands such as <code>hermes status</code>,
      <code>hermes tools</code>, and <code>hermes logs</code>.
    </p>

    <div class="term">
      <iframe src="./terminal/" title="Hermes terminal"></iframe>
    </div>
  </div>
</body>
</html>
