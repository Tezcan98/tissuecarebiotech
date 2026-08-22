# TissueCare Biotech — Kurumsal Web Sitesi

Statik HTML/CSS/JS mimarisi ile hazırlanan kurumsal tanıtım sitesi.

## Yapı

```
index.html          # Ana sayfa (şirket bilgileri gelene kadar "yakında" ekranı)
css/style.css        # Stiller
js/                  # İçerik netleşince eklenecek scriptler
assets/images/       # Görseller
```

## Durum

Şirket içerikleri (hakkımızda, hizmetler, iletişim vb.) henüz teslim edilmedi.
Bu yüzden ana sayfa geçici olarak bir "yakında" ekranı gösteriyor. İçerikler
gelince bölümler (Hero, Hakkımızda, Ürünler/Hizmetler, İletişim) eklenecek.

## Deploy

Site sunucuda `/home/tissuecarebiotech` altında, `serve` ile systemd servisi
olarak (port 4001) çalışır; nginx bu porta reverse proxy yapar.

- İlk kurulum (sunucuda bir kez): `deploy/server-setup.sh` — bkz. script
  içindeki açıklama. systemd unit dosyasını (`deploy/tissuecarebiotech.service`)
  ve nginx konfigürasyonunu (`deploy/tissuecarebiotech.nginx.conf`) kurar,
  certbot ile SSL alır.
- Her değişiklikten sonra: `./deploy.sh` — dosyaları rsync ile
  `/home/tissuecarebiotech`'e senkronize eder.
