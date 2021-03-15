## Requirements

```bash
python3 -m venv venv
source venv/bin/activate
pip install -U wheel
pip install -r requirements.txt
```

## Scrapy

```bash
scrapy startproject books
```

You can start your first spider with:

```bash
cd books
scrapy genspider books.toscrape books.toscrape.com
```
### Running the spider
```bash
scrapy crawl books.toscrape -o books.json
```

This is a Scrapy project to scrape books from [http://books.toscrape.com](http://books.toscrape.com).