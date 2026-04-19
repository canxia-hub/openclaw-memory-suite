# Contributing to OpenClaw Memory Suite

Thank you for your interest in contributing! 🎉

---

## 🌟 Ways to Contribute

- **Bug Reports** — Submit issues for bugs you find
- **Feature Requests** — Suggest new features or improvements
- **Documentation** — Improve or translate documentation
- **Code** — Submit pull requests for bug fixes or features
- **Testing** — Test new releases and report issues

---

## 🐛 Bug Reports

When submitting a bug report, please include:

1. **OpenClaw Version**: `openclaw --version`
2. **Plugin Version**: Check `package.json` or `openclaw.plugin.json`
3. **Steps to Reproduce**: Detailed steps
4. **Expected Behavior**: What you expected
5. **Actual Behavior**: What actually happened
6. **Logs**: Relevant error messages or logs

---

## 💡 Feature Requests

For feature requests, please describe:

1. **Use Case**: Why you need this feature
2. **Proposed Solution**: How you think it should work
3. **Alternatives**: Other approaches you've considered

---

## 🔧 Pull Requests

### Before Submitting

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes thoroughly
4. **Document** your changes in code comments and docs

### Commit Guidelines

Use clear commit messages:

- `feat: add new feature`
- `fix: resolve bug in retrieval`
- `docs: update installation guide`
- `refactor: improve code structure`
- `test: add unit tests`

### PR Checklist

- [ ] Code follows project style
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] PR description explains changes

---

## 📚 Documentation

When updating documentation:

1. Keep it **concise** and **clear**
2. Use **examples** for complex concepts
3. Update **README** if needed
4. Add **cross-references** to related docs

---

## 🧪 Testing

Before submitting PRs:

```bash
# Run plugin tests
cd components/memory-lancedb-pro
npm test

# Run wiki lint
cd components/graphify-openclaw/scripts
python wiki_ops.py doctor

# Run health check
openclaw doctor --non-interactive
```

---

## 📝 Code Style

### TypeScript

- Use strict type checking
- Document public APIs with JSDoc
- Follow existing code patterns

### Python

- Follow PEP 8
- Use type hints
- Document functions with docstrings

### Markdown

- Use proper heading hierarchy
- Include code examples in fenced blocks
- Link to related documentation

---

## 🤝 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the community

---

## 📞 Questions?

- **GitHub Issues** — For bugs and features
- **GitHub Discussions** — For questions and ideas
- **Discord** — For real-time chat

---

Thank you for contributing! 💙
