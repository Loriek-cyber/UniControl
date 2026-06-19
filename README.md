# UniControl - Premium Flutter Setup

Welcome to the **UniControl** repository! This project has been bootstrapped with a premium, clean architecture-ready Flutter setup.

## Features Included
- **Strict Linting**: Configured with `analysis_options.yaml` for enforcing best practices, sorted imports, and clean code.
- **VS Code Configuration**: Pre-configured settings (`.vscode/`) for formatting on save, organizing imports, useful extensions, and launch profiles.
- **Clean Architecture Skeleton**: Organized directory structure inside `lib/src/` to separate features and core utilities.
- **GitHub Actions CI/CD**: Automated builds for Android, iOS, Windows, and Linux on push/pull request via `.github/workflows/flutter_build.yml`.

## Prerequisites

If you haven't installed Flutter yet:
1. Ensure your system PATH is configured correctly if you installed it via chocolatey (`sudo choco install flutter`). You might need to restart your terminal or VS Code.
2. Verify your installation by running:
   ```bash
   flutter doctor
   ```

## Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the App**:
   - You can use the Run/Debug panel in VS Code (which uses the provided `launch.json`).
   - Or run from the command line:
     ```bash
     flutter run
     ```

## Project Structure
```text
lib/
├── src/
│   ├── core/
│   │   ├── theme/          # Theming configurations
│   │   └── utils/          # Global utilities and helpers
│   └── features/
│       └── home/           # Example feature
│           ├── presentation/ # Screens, widgets, blocs/controllers
│           ├── domain/       # Use cases, entities, repository interfaces
│           └── data/         # Models, data sources, repository implementations
└── main.dart               # App entrypoint
```

## Contributing
When writing code, ensure that your editor is formatting on save and organizing imports. Our strict `analysis_options.yaml` will help keep the codebase maintainable.
