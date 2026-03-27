## v0.7.0

- **New Command `frx hooks`**: Added a dedicated command for managing git hooks.
  - `frx hooks install`: Install all enabled hooks into `.git/hooks/`
  - `frx hooks uninstall`: Remove all FRX-managed git hooks
  - `frx hooks list`: Show all configured hooks and their install status
  - `frx hooks run <name>`: Manually trigger a git hook by name
  - `frx hooks validate`: Validate your hooks configuration
- **Enhanced `config.yaml`**: Added a new `hooks:` section for configuring git hooks.
- **Improved `frx init`**: Updated the starter configuration template with the new hooks format and comprehensive examples for common workflows.
- **Documentation**: Updated `README.md` with a detailed hooks section and better guidance.

## v0.6.0

- **New Command `frx pipeline`**: Added a dedicated command for managing and running pipelines.
  - `frx pipeline list`: List all configured pipelines with descriptions and step counts.
  - `frx pipeline validate`: Robust validation of pipeline configurations with descriptive error and warning messages.
  - `frx pipeline run <name>`: Run a specific named pipeline.
  - `frx pipeline help-all`: Comprehensive feature reference for pipeline configuration.
- **Enhanced Pipeline System**:
  - Support for multiple named pipelines in `config.yaml`.
  - Added new per-step configuration options: `env`, `timeout`, `retry`, `retry_delay`, `condition`, `working_directory`, `continue_on_error`, `allow_failure`, `stop_on_failure`, `upload_output`, `output_path`, `notify_slack`, `notify_teams`, `custom_exit_condition`, and `depends_on`.
- **Improved `frx build`**: Added `--pipeline <name>` flag to execute a specific pipeline directly from the build command.
- **Enhanced `frx init`**: Updated the starter configuration template with the new pipeline format and comprehensive examples for common workflows.
- **Dependency Update**: Bumped `googleapis` from `^15.0.0` to `^16.0.0`.
- **Documentation**: Updated `README.md` with a detailed pipeline step reference table and better guidance.

## v0.5.0

- **New `frx init` command**: Quickly initialize a new FRX project with a starter `config.yaml` file containing all options, helpful comments, and multi-framework pipeline examples.
- **Automatic Update Checking**: FRX now automatically checks for updates in the background when you run commands (cached for 24 hours).
- **Manual Update Check**: Added `frx check-update` command to manually check for new versions.
- **Enhanced Pipeline Examples**: Added comprehensive pipeline examples for multiple frameworks (Flutter, React, Python, .NET, Go, Docker, etc.) in the starter config.
- **Improved Documentation**: Updated all documentation to reflect new features and provide better guidance for new users.

## v0.4.0

- Added new upload options: **GitLab, Diawi, AWS, Google Play Store, and Apple App Store**.
- Introduced **Microsoft Teams** support for faster and easier team notifications.
- Improved QR code generation and sharing.
- Various performance and stability optimizations.

## v0.3.2

- add version command
- optimize google drive upload
- update dependencies

## v0.3.1

- add discord community
- improve docs

## v0.3.0

- Added `notify` command to send notifications (Slack supported).
- Added `--target` to build for all platforms in one go or just specified ones.
- Improved CLI documentation and examples.

## v0.2.2

- improve docs.

## v0.2.1

- add better documentation.

## v0.2.0

### New Features

- **Pipeline System**:
  - Introduced a powerful new pipeline feature that allows users to automate a series of tasks with customizable conditions.
  - The pipeline supports key configurations such as `customExitCondition`, `uploadOutput`, `notifySlack`, and more to offer fine-grained control over the flow of tasks.

### Enhancements

- **Documentation**:
  - Comprehensive updates to the documentation, including detailed examples and explanations of the new pipeline system.
  - Added clear instructions on how to configure and use the pipeline, ensuring an easier onboarding process.

## v0.1.2

- **Added Gitignore Section**: Included a Gitignore section in the documentation to guide best practices and prevent committing sensitive information.
- **Removed Redundant Dependencies**: Cleaned up unnecessary dependencies.
- **Availability Flags**: Real-time update for upload options showing which are configured and available.

## 0.1.1

- **Updated Documentation**: Enhanced clarity, reorganized sections, and added detailed instructions for easier setup and usage.
- **Video Tutorial**: Released a comprehensive video tutorial to walk users through the setup process and highlight key features.

## 0.1.0

- **New Feature**: Added **Slack Integration** for seamless build sharing and notifications.
- **Updated Documentation**: Improved clarity and added new sections for Slack integration setup.
- **Optimizations**: Enhanced performance for faster build generation and smoother user experience.

## 0.0.4

- Added new commands: `frx build --config` & `frx build --show-config` for easier configuration management.
- Updated dependency: Required `path: ^1.9.0`.
- Optimized performance for a smoother experience.

## 0.0.3

- Add example and improvements.

## 0.0.2

- Improve documentation & optimizations.

## 0.0.1

### Added

- Initial release of Flutter Release X.
- Support for building release APKs.
- GitHub upload integration.
- QR code generation for APK download links.
- Google Drive upload integration.
- Upload link generation for APKs.
- Detailed configuration instructions for GitHub and Google Drive.
