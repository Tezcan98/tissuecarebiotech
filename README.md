# TissueCare Biotech — Kurumsal Web Sitesi

Statik HTML/CSS/JS mimarisi ile hazırlanan kurumsal tanıtım sitesi.

## Yapı

```
index.html          # Ana sayfa (Biz Kimiz, Tekniklerimiz, Hizmetlerimiz, Alt Yapımız, İletişim)
css/style.css        # Stiller
js/main.js           # Mobil menü aç/kapat
assets/images/       # Görseller
```

## Durum

Kurumsal içerik (misyon/vizyon/değerler, teknikler, alt yapı) eklendi.
Hizmetlerimiz/Satışlarımız bölümündeki bazı başlıkların altı ve iletişim
bilgilerinden adres/e-posta henüz teslim edilmedi, sayfada "İçerik
hazırlanıyor" / "Yakında eklenecek" olarak işaretli.

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
