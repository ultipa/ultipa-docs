# Troubleshooting

This section catalogs common GQLDB issues and how to resolve them. Each page groups symptoms (what you see) with diagnostics (how to confirm) and fixes (how to resolve).

## How to use this section

1. **Search by symptom:** the page titles and section headings describe what you actually observed in your client output, not the underlying engine concept. If you saw an error message, search for a fragment of it; if you got an empty result, search for the operation you ran.
2. **Confirm the diagnosis:** most pages include a "How to confirm" block with a follow-up query or check that distinguishes one cause from another.
3. **Apply the fix:** the resolution is usually a single statement change, a configuration flip, or a re-run.

## When to look elsewhere

- **Syntax reference:** see <a href="/docs/gql" target="_blank">ISO GQL</a> for the canonical grammar and semantics. If your statement parses but doesn't behave as expected, this Troubleshooting section is the right place.
- **Driver-specific errors:** see <a href="/docs/drivers" target="_blank">Ultipa Drivers</a>.
- **Performance tuning:** covered under <a href="/docs/computing-engine" target="_blank">Computing Engine</a> and the query-execution guides under <a href="/docs/gql" target="_blank">ISO GQL</a>.

## Reporting a new issue

If your symptom isn't covered here, file a report through your standard support channel or email <a href="mailto:support@ultipa.com">support@ultipa.com</a>. To help us reproduce and fix the issue quickly, include:

1. The exact statement that triggered the problem.
2. The output of `RETURN db.version()`.
3. The relevant `Response.Warnings` from the driver, if any.
4. The graph creation statement (so we know whether `WITH ONTOLOGY`, `EDGE_ID`, etc. are in play).
