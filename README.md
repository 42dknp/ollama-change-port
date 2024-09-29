# Ollama Service Port Change Script

This guide describes how to use a shell script to change the port on which the Ollama service is running by editing the systemd service file for Ollama. The script handles the `OLLAMA_HOST` environment variable via a systemd override file, so changes can easily be reset by deleting the override.


## Compatibility

This script has been tested on **Ubuntu** and is expected to work on other Linux distributions that use **systemd** for managing services. 

### Tested:
- **Ubuntu** (WSL 2 Version on Windows)

### Known Limitations:
- **Non-systemd distributions** (e.g., Alpine Linux, Devuan) will not be compatible with this script without modification, as they use different init systems like OpenRC or SysVinit. 

In general, as long as the Linux distribution uses **systemd**, the script should work seamlessly for managing the `OLLAMA_HOST` configuration and restarting services. If you're using a non-systemd distribution, you'll need to adapt the script to match the init system in use.


## Usage

### Change the Port

1. Save the script to a file by downloading it from the following GitHub repository:

   You can use the `curl` or `wget` command to download the script directly from GitHub (replace `main` with the correct branch if needed):

   Using `curl`:
   ```bash
   curl -o change_ollama_port.sh https://raw.githubusercontent.com/42dknp/ollama-change-port/main/change_ollama_port.sh
   ```

   Or using `wget`:
   ```bash
   wget -O change_ollama_port.sh https://raw.githubusercontent.com/42dknp/ollama-change-port/main/change_ollama_port.sh
   ```

2. Before running the script, **it is highly recommended to review the contents of the script** to ensure it is safe and does exactly what is described. This is a standard security best practice when running scripts with administrative privileges.

   You can open and inspect the script by using a text editor, for example:

   ```bash
   nano change_ollama_port.sh
   ```

3. Give the script executable permissions by running the following command:

   ```bash
   chmod +x change_ollama_port.sh
   ```

4. Run the script with `sudo`, passing the new port as an argument. For example, to change the port to `5050`, use the following command:

   ```bash
   sudo ./change_ollama_port.sh 5050
   ```

   By default, the script checks if the `OLLAMA_HOST` entry already exists. If it does, the script will **not** overwrite it unless the `--overwrite` option is used.

### Force Overwrite the Port

If you already know that the `OLLAMA_HOST` exists but want to force overwrite it with a new port:

```bash
sudo ./change_ollama_port.sh <new_port> --overwrite
```

Example (to force the change to port `5050`):

```bash
sudo ./change_ollama_port.sh 5050 --overwrite
```

The script will update the `OLLAMA_HOST` entry in the override file located at `/etc/systemd/system/ollama.service.d/override.conf`.

---

## Resetting to Default Configuration

If you want to **reset the service to its default configuration** (i.e., remove the custom `OLLAMA_HOST` setting and revert to the default port), follow these steps:

1. Delete the override file:
   ```bash
   sudo rm /etc/systemd/system/ollama.service.d/override.conf
   ```

2. Reload the systemd daemon to remove the override:
   ```bash
   sudo systemctl daemon-reload
   ```

3. Restart the Ollama service:
   ```bash
   sudo systemctl restart ollama.service
   ```

Once the override file is deleted and the service is restarted, the Ollama service will revert to using the default port (if defined in the base service file).

---

## Using Ollama with the New Port

After changing the port, you will need to use Ollama with the updated host and port settings. To do this, prepend the `OLLAMA_HOST` environment variable to your Ollama commands like this:

- To list models:

  ```bash
  OLLAMA_HOST=127.0.0.1:5050 ollama list
  ```

- To run a model (for example, `gemma2:27b`):

  ```bash
  OLLAMA_HOST=127.0.0.1:5050 ollama run gemma2:27b
  ```

Replace `127.0.0.1:5050` with the correct host and port if you're using a different one.

---

## Security Best Practice

**Important:** Before running the script as an administrator (`sudo`), it's essential to open and review the script to ensure it aligns with the description and performs only the tasks mentioned. This helps to ensure you are not running anything harmful or unintended.

---

This process simplifies the task of updating or resetting the Ollama service's port configuration while adhering to security best practices.
