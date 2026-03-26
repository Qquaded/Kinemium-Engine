local net = zune.net

local kinemium_http = {}

function kinemium_http:Init(renderer)
	net.http.serve({
		port = math.random(4000, 10000),
		address = "0.0.0.0",
		request = function(req: HttpServerRequest)
			local page = [[
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kinemium Perf Stats</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;500;600;700&display=swap');

        :root {
            --bg: #000000;
            --surface: #0a0a0a;
            --surface-2: #111111;
            --border: #1a1a1a;
            --border-bright: #2a2a2a;
            --accent: #ff6a00;
            --accent-dim: rgba(255, 106, 0, 0.08);
            --accent-glow: rgba(255, 106, 0, 0.3);
            --text: #ffffff;
            --text-muted: #555555;
            --text-dim: #888888;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'JetBrains Mono', monospace;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* ── Top bar ── */
        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 32px;
            height: 56px;
            border-bottom: 1px solid var(--border);
            background: var(--surface);
            flex-shrink: 0;
        }

        .topbar-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .logo {
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.12em;
            color: #fff;
        }

        .logo span { color: var(--accent); }

        .divider {
            width: 1px;
            height: 16px;
            background: var(--border-bright);
        }

        .badge {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 10px;
            font-weight: 500;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: var(--accent);
        }

        .badge-dot {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            background: var(--accent);
            box-shadow: 0 0 6px var(--accent);
            animation: blink 2s ease-in-out infinite;
        }

        @keyframes blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.2; }
        }

        .topbar-right {
            font-size: 10px;
            color: var(--text-muted);
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .page-header {
            padding: 48px 32px 36px;
            border-bottom: 1px solid var(--border);
        }

        .eyebrow {
            font-size: 10px;
            font-weight: 500;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 12px;
        }

        h1 {
            font-size: 42px;
            font-weight: 700;
            letter-spacing: -0.03em;
            color: #fff;
            line-height: 1;
        }

        h1 em {
            font-style: normal;
            color: var(--accent);
        }

        /* ── Table wrapper ── */
        .table-wrap {
            flex: 1;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead tr {
            border-bottom: 1px solid var(--border-bright);
        }

        th {
            padding: 12px 32px;
            text-align: left;
            font-size: 9px;
            font-weight: 600;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: var(--text-muted);
            background: var(--surface);
            white-space: nowrap;
        }

        td {
            padding: 16px 32px;
            font-size: 13px;
            font-weight: 400;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }

        tbody tr {
            transition: background 0.1s ease;
        }

        tbody tr:hover {
            background: var(--surface-2);
        }

        tbody tr:hover td.prop-name {
            color: #fff;
        }

        tbody tr:last-child td {
            border-bottom: none;
        }

        .prop-name {
            color: var(--text-dim);
            font-weight: 500;
            font-size: 12px;
            letter-spacing: 0.02em;
            width: 40%;
        }

        .prop-value {
            color: #fff;
            font-weight: 400;
        }

        /* ── Footer ── */
        .footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 32px;
            height: 44px;
            border-top: 1px solid var(--border);
            background: var(--surface);
            flex-shrink: 0;
        }

        .footer-text {
            font-size: 10px;
            color: var(--text-muted);
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .footer-accent {
            font-size: 10px;
            color: var(--accent);
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }
    </style>
</head>
<body>

    <div class="topbar">
        <div class="topbar-left">
            <div class="logo">KINE<span>MIUM</span></div>
            <div class="divider"></div>
            <div class="badge">
                <div class="badge-dot"></div>
                Live
            </div>
        </div>
        <div class="topbar-right">Port 7000</div>
    </div>

    <div class="page-header">
        <div class="eyebrow">Renderer Diagnostics</div>
        <h1>Perf <em>Stats</em></h1>
    </div>

    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Property</th>
                    <th>Value</th>
                </tr>
            </thead>
            <tbody>
            ]]

			for prop, value in pairs(renderer.PerfStats) do
				page = page
					.. string.format(
						'<tr><td class="prop-name">%s</td><td class="prop-value">%s</td></tr>',
						prop,
						tostring(value)
					)
			end

			page = page
				.. [[
            </tbody>
        </table>
    </div>

    <div class="footer">
        <span class="footer-text">kinemium engine</span>
        <span class="footer-accent">&#9632; Running</span>
    </div>

</body>
</html>
            ]]

			return {
				status_code = 200,
				headers = { ["Content-Type"] = "text/html" },
				body = page,
			}
		end,
	})
end

return kinemium_http
