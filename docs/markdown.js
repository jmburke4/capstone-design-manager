async function renderMarkdown(iframeId, markdownPath) {
    const container = document.getElementById(iframeId);
    if (!container) throw new Error(`Container not found: ${iframeId}`);

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

    const renderedContainer = document.createElement("div");
    renderedContainer.innerHTML = renderedHtml;

    const usedIds = new Map();
    renderedContainer.querySelectorAll("h1, h2, h3, h4, h5, h6").forEach((heading, index) => {
        const headingText = (heading.textContent || "").trim();
        const normalizedHeadingText = headingText.replace(/^\d+(?:\.\d+)*(?:[.)]|\s|-)*\s*/, "");
        let slug = normalizedHeadingText
            .toLowerCase()
            .replace(/[^a-z0-9\s-]/g, "")
            .replace(/\s+/g, "-")
            .replace(/-+/g, "-")
            .replace(/^-|-$/g, "");

        if (!slug) {
            slug = `section-${index + 1}`;
        }

        const count = usedIds.get(slug) || 0;
        usedIds.set(slug, count + 1);
        heading.id = count === 0 ? slug : `${slug}-${count + 1}`;
    });

    // Load GitHub markdown styles once in the host document.
    if (!document.getElementById("github-markdown-css")) {
        const link = document.createElement("link");
        link.id = "github-markdown-css";
        link.rel = "stylesheet";
        link.href = "https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.8.1/github-markdown.min.css";
        document.head.appendChild(link);
    }

    if (!document.getElementById("render-markdown-style")) {
        const style = document.createElement("style");
        style.id = "render-markdown-style";
        style.textContent = `
            .rendered-markdown {
                margin: 0;
                padding: 16px;
                background: white;
            }
            .rendered-markdown .markdown-body {
                box-sizing: border-box;
                min-width: 200px;
                max-width: 100%;
                margin: 0 auto;
            }
        `;
        document.head.appendChild(style);
    }

    container.classList.add("rendered-markdown");
    container.innerHTML = `<article class="markdown-body">${renderedContainer.innerHTML}</article>`;
}
