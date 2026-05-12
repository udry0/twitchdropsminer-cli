# TwitchDropsMiner CLI / Headless (Bahasa Indonesia)

Repo ini adalah versi modifikasi dari TwitchDropsMiner supaya bisa dipakai tanpa GUI, fokus ke mode CLI/headless dan setup multi-account per instance.

## Fitur yang ditambah

- Mode `--cli` tanpa Tk GUI
- Login Twitch via device code dari terminal
- Runner headless `run_headless.sh`
- CLI override:
  - `--priority`
  - `--exclude`
  - `--priority-mode`
  - `--available-drops-check`
  - `--no-available-drops-check`
  - `--connection-quality`
- Setup multi-account terpisah per folder
- Template systemd untuk jalan 24/7

## Batasan penting

- Ini **bukan** multi-account native dalam satu proses.
- Model yang dipakai adalah **satu akun Twitch = satu folder kerja = satu service / satu instance**.
- Mau 2 akun, 5 akun, 10 akun, sampai 20 akun? Bisa, asal dipisah per instance.
- Account linking Twitch ke akun game/publisher tetap **harus manual** lewat browser resmi Twitch/publisher.

## Requirement

- Linux
- Python 3.10+
- Disarankan pakai virtualenv `env/`

## Install cepat

```bash
git clone https://github.com/udry0/twitchdropsminer-cli.git
cd twitchdropsminer-cli
./setup_env.sh
```

Kalau `setup_env.sh` gagal karena dependency GUI Linux, lu tetap bisa pakai mode CLI dengan install kebutuhan minimum sendiri. Yang paling penting minimal Python jalan, plus dependency dasar project.

## Jalankan 1 akun

```bash
python3 main.py --cli --log
```

Atau pakai wrapper:

```bash
./run_headless.sh
```

### Login pertama kali

Saat pertama jalan, terminal bakal nampilin URL aktivasi Twitch dan device code.

Contoh:

```text
Open this URL in your browser: https://www.twitch.tv/activate?device-code=ABCDEFGH
Enter this Twitch device code: ABCDEFGH
```

Langkahnya:

1. buka URL yang dikasih
2. login ke akun Twitch yang mau dipakai
3. approve device code
4. tunggu miner lanjut sendiri

Kalau sukses, nanti session/cookie kesimpan di folder akun itu.

## Bedain 2 hal ini

### 1. Authorize miner ke akun Twitch
Bisa dilakukan dari mode CLI lewat device code login.

### 2. Link akun Twitch ke akun game/publisher
Ini **tidak otomatis**. Lu harus link manual lewat halaman drops campaign / situs publisher.

## Contoh CLI override

```bash
python3 main.py --cli --log \
  --priority "Legend of YMIR" \
  --exclude "Dota 2" \
  --priority-mode ending-soonest \
  --connection-quality 4 \
  --available-drops-check
```

## Multi-account

### Konsep

Setiap akun punya folder sendiri, misalnya:

```text
accounts/
  acc1/
    .env
    cookies.jar
    settings.json
    log.txt
  acc2/
    .env
    cookies.jar
    settings.json
    log.txt
```

Jadi tiap akun terisolasi. Ini jauh lebih aman daripada maksa banyak akun dalam satu folder.

### Generate default multi-account

Script bawaan default bikin **2 akun**, tapi bisa lu ubah bebas.

```bash
./setup_multi_account.sh
```

Itu default bikin:

```text
accounts/acc1
accounts/acc2
```

Kalau mau 5 akun:

```bash
./setup_multi_account.sh ./accounts 5
```

Kalau mau 10 akun:

```bash
./setup_multi_account.sh ./accounts 10
```

Kalau mau 20 akun:

```bash
./setup_multi_account.sh ./accounts 20
```

Range yang disupport script: **1 sampai 20 akun**.

### Konfigurasi per akun

Edit file `.env` di masing-masing akun.

Contoh `accounts/acc1/.env`:

```bash
TDM_ACCOUNT_NAME=acc1
TDM_PRIORITY=Legend of YMIR
TDM_EXCLUDE=
TDM_PRIORITY_MODE=priority-only
TDM_CONNECTION_QUALITY=3
TDM_AVAILABLE_DROPS_CHECK=0
TDM_FORCE_DISABLE_DROPS_CHECK=1
TDM_VERBOSE=-vv
TDM_EXTRA_ARGS=
```

Contoh `accounts/acc2/.env`:

```bash
TDM_ACCOUNT_NAME=acc2
TDM_PRIORITY=VALORANT
TDM_EXCLUDE=
TDM_PRIORITY_MODE=priority-only
TDM_CONNECTION_QUALITY=3
TDM_AVAILABLE_DROPS_CHECK=0
TDM_FORCE_DISABLE_DROPS_CHECK=1
TDM_VERBOSE=-vv
TDM_EXTRA_ARGS=
```

### Jalankan akun tertentu

Akun 1:

```bash
TDM_ACCOUNT_NAME=acc1 ./run_headless.sh
```

Akun 2:

```bash
TDM_ACCOUNT_NAME=acc2 ./run_headless.sh
```

Akun 5:

```bash
TDM_ACCOUNT_NAME=acc5 ./run_headless.sh
```

Kalau folder `accounts/accX` belum ada, bikin dulu lewat `setup_multi_account.sh`.

## File penting runner

### `run_headless.sh`
Runner utama. Secara default:

- pakai `env/bin/python` kalau ada
- kalau nggak ada, fallback ke `python3`
- pindah working directory ke folder akun masing-masing
- load `.env` dari folder akun kalau ada

### Env vars yang dipakai runner

- `TDM_ACCOUNT_NAME`
- `TDM_ACCOUNT_ROOT`
- `TDM_ACCOUNT_DIR`
- `TDM_ENV_FILE`
- `TDM_PRIORITY`
- `TDM_EXCLUDE`
- `TDM_PRIORITY_MODE`
- `TDM_CONNECTION_QUALITY`
- `TDM_AVAILABLE_DROPS_CHECK`
- `TDM_FORCE_DISABLE_DROPS_CHECK`
- `TDM_VERBOSE`
- `TDM_EXTRA_ARGS`

## Systemd (24/7)

Template service multi-account ada di:

```text
contrib/twitchdropsminer-account@.service
```

### Install service

```bash
sudo mkdir -p /opt/twitchdropsminer
sudo rsync -a ./ /opt/twitchdropsminer/
sudo cp /opt/twitchdropsminer/contrib/twitchdropsminer-account@.service /etc/systemd/system/
sudo systemctl daemon-reload
```

### Siapkan akun default 2 akun di lokasi production

```bash
cd /opt/twitchdropsminer
./setup_multi_account.sh /opt/twitchdropsminer/accounts 2
```

### Jalankan account 1

```bash
sudo systemctl enable --now twitchdropsminer-account@acc1
sudo journalctl -u twitchdropsminer-account@acc1 -f
```

### Jalankan account 2

```bash
sudo systemctl enable --now twitchdropsminer-account@acc2
sudo journalctl -u twitchdropsminer-account@acc2 -f
```

### Jalankan banyak akun sekaligus

Misal acc1 sampai acc5:

```bash
for i in 1 2 3 4 5; do
  sudo systemctl enable --now twitchdropsminer-account@acc$i
 done
```

### Stop akun tertentu

```bash
sudo systemctl stop twitchdropsminer-account@acc3
```

### Disable akun tertentu

```bash
sudo systemctl disable twitchdropsminer-account@acc3
```

## Saran layout production

Kalau mau rapi:

```text
/opt/twitchdropsminer/
  main.py
  run_headless.sh
  setup_multi_account.sh
  accounts/
    acc1/
    acc2/
    acc3/
    ...
```

## Cara pakai buat Legend of YMIR

Set di `.env` akun:

```bash
TDM_PRIORITY=Legend of YMIR
TDM_PRIORITY_MODE=priority-only
```

Lalu jalankan akun itu. Kalau campaign aktif dan akun Twitch lu eligible, miner bakal fokus ke YMIR.

## Troubleshooting

### 1. Miner idle / `No active campaigns to mine drops for`
Biasanya karena:
- campaign memang belum aktif
- akun Twitch belum eligible
- akun belum link ke publisher/game
- `priority-only` aktif tapi `TDM_PRIORITY` kosong / salah nama game

### 2. Device code udah di-approve tapi miner nggak lanjut
Coba:
- pastiin login di browser pakai akun Twitch yang bener
- ulang login dengan restart miner
- cek apakah `cookies.jar` kebentuk di folder akun

### 3. Beberapa akun mau jalan bareng
Bisa, tapi **wajib folder akun terpisah**. Jangan share `cookies.jar` dan `settings.json` antar akun.

### 4. Mau lebih aman
Kalau jalan banyak akun, lebih aman pakai:
- IP/proxy berbeda per akun
- ritme penggunaan yang wajar
- jangan buka stream manual di akun Twitch yang sama saat miner aktif

## Status project ini

Project ini adalah adaptasi headless/CLI dari TwitchDropsMiner. Fokusnya bikin miner lebih gampang dijalankan di server/Linux tanpa GUI, plus mendukung setup banyak akun lewat instance terpisah.

Kalau lu mau nambah fitur lagi, yang paling masuk akal berikutnya:
- installer 1 command
- healthcheck
- rotasi log
- monitoring status per akun
