# get.emuvlucht.my.id — GitHub Pages + APK Daemon

Deploy web redirect untuk daemon script APK auto-updater.

---

## 📁 Struktur File

```
get-emuvlucht/
├── index.html                  # Landing page utama
├── getApp/
│   └── index.html              # ← Endpoint yang dibaca daemon (var redirectUrl)
├── CNAME                       # Custom domain
├── .github/workflows/
│   └── update-redirect.yml     # Auto-update redirectUrl saat release baru
└── build-apk.sh                # Script build APK sederhana (opsional)
```

---

## 🚀 Cara Deploy ke GitHub Pages

### 1. Buat repo baru di GitHub
```
Nama repo: get.emuvlucht.my.id   (atau nama bebas)
Visibility: Public
```

### 2. Upload semua file ini ke repo
```bash
git init
git remote add origin https://github.com/OWNER/get.emuvlucht.my.id.git
git add .
git commit -m "init: setup github pages + getApp endpoint"
git push -u origin main
```

### 3. Aktifkan GitHub Pages
- Buka **Settings → Pages**
- Source: **Deploy from a branch**
- Branch: `main` / `(root)`
- Simpan

### 4. Atur Custom Domain
- Masukkan `get.emuvlucht.my.id` di kolom Custom domain
- Centang **Enforce HTTPS**

### 5. Atur DNS di provider domain kamu
Tambahkan record CNAME:
```
Type:  CNAME
Host:  get
Value: OWNER.github.io
TTL:   3600
```

---

## ✏️ Update URL APK

### Manual — edit file `getApp/index.html`
Cari baris:
```javascript
var redirectUrl = "https://...APK_LAMA...";
```
Ganti ke URL APK terbaru, lalu commit & push.

### Otomatis — GitHub Actions
Saat kamu publish **Release baru** di GitHub yang menyertakan file `.apk`,
workflow `.github/workflows/update-redirect.yml` akan otomatis memperbarui `redirectUrl`.

Atau trigger manual:
- **Actions → Update APK Redirect → Run workflow**
- Masukkan URL APK langsung

---

## 📱 Format Nama File APK

Daemon script mengubah nama file:
```
app25301.apk  →  com.kcstream.cing_2.5.3-build01.apk
     ↑↑↑↑↑
     │││└┴─ build (2 digit)
     ││└─── patch
     │└──── minor  
     └───── major
```

---

## 🔧 Test Endpoint Daemon

```bash
# Test apakah endpoint bisa dibaca daemon
curl -s "https://get.emuvlucht.my.id/getApp/" \
  | grep -oP 'var redirectUrl = "\K[^"]+'
```

Harus mengembalikan URL APK secara langsung.

---

## 🤖 Daemon Script Config

Update `config.sh` di server kamu:
```bash
# config.sh
URL="https://get.emuvlucht.my.id/getApp/"
```

---

## 📦 Build APK Sederhana (WebView)

Kalau ingin APK yang membuka halaman `get.emuvlucht.my.id/getApp/`:

```bash
# Perlu: JDK + Android SDK
chmod +x build-apk.sh
./build-apk.sh
```

Atau pakai Android Studio dengan template **Empty Views Activity** + tambah WebView
yang load URL `https://get.emuvlucht.my.id/getApp/`.
