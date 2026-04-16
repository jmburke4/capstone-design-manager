async function renderMarkdown(iframeId, markdownPath) {
    const iframe = document.getElementById(iframeId);
    if (!iframe) throw new Error(`Iframe not found: ${iframeId}`);

    const mdResponse = await fetch(markdownPath);
    if (!mdResponse.ok) {
        throw new Error(`Failed to load markdown file: ${markdownPath}`);
    }
    const markdownText = await mdResponse.text();

    const ghResponse = await fetch("https://api.github.com/markdown", {
        method: "POST",
        headers: {
            "Accept": "text/html",
            "Content-Type": "application/json",
            "X-GitHub-Api-Version": "2026-03-10"
        },
        body: JSON.stringify({
            text: markdownText,
            mode: "markdown"
        })
    });

    if (!ghResponse.ok) {
        const errorText = await ghResponse.text();
        throw new Error(`GitHub Markdown API error (${ghResponse.status}): ${errorText}`);
    }

    const renderedHtml = await ghResponse.text();

    const doc = iframe.contentDocument || iframe.contentWindow.document;
    doc.open();
    doc.write(`<!doctype html>
<html>
<head>
    <meta charset="UTF-8" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.8.1/github-markdown.min.css">
    <style>
        body {
            margin: 0;
            padding: 16px;
            background: white;
        }
        .markdown-body {
            box-sizing: border-box;
            min-width: 200px;
            max-width: 100%;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <article class="markdown-body">
        ${renderedHtml}
    </article>
</body>
</html>`);
    doc.close();
}
