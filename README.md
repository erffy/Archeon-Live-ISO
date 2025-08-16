## Archeon Live ISO

This is the live ISO I’ve set up for myself, which I call **Archeon**.

### Building

#### 1. Install Required Dependencies

```bash
sudo pacman -S --needed git archiso squashfs-tools
```

#### 2. Clone Repository

```bash
git clone https://github.com/erffy/Archeon-Live-ISO.git archeon && cd archeon
```

#### 3. Build ISO

```bash
./build.sh
```

### Notes
- Ensure you have sufficient disk space for building the ISO.
- The build process may take some time depending on your system.
- After building, the ISO will be located in the `dist/` directory inside the repository.
