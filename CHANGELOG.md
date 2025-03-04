# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2025-03-04

### Added
- Docker autostart support
  - Headless support
  - Automatic Colima installation and configuration
  - Configurable via DOCKER_AUTOSTART environment variable
  - Enables headless container operation

## [1.1.0] - 2025-03-01

### Added
- GPU Memory Optimization feature
  - Configurable GPU memory allocation via OLLAMA_GPU_PERCENT environment variable
  - Automatic allocation at system startup
  - Documentation on Metal memory allocation behavior

### Changed
- Made user configuration more flexible with environment variables
- Improved documentation with performance considerations
- Enhanced installation script with better error handling

## [1.0.0] - 2025-02-28

### Added
- Initial release
- System optimization for Mac Studio
- Ollama service configuration
- Automatic startup
- Memory usage reduction (11GB → 3GB)
- External network access
- Logging setup 