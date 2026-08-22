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

`./deploy.sh` sunucuda, `/home/tissuecarebiotech` altına klonlanmış bu
repo'nun içinden root olarak çalıştırılır. `git pull` ile içeriği
günceller, ardından sunucudaki diğer sitelere dokunmadan
`tissuecarebiotech.com` / `www.tissuecarebiotech.com` için nginx
config'ini ekleyip nginx'i reload eder.

İlk kurulum (bir kereye mahsus, sunucuda elle):

```
git clone https://github.com/Tezcan98/tissuecarebiotech.git /home/tissuecarebiotech
cd /home/tissuecarebiotech
./deploy.sh
```
