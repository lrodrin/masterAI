## Requirements

```bash
python3 -m venv venv
source venv/bin/activate
pip install -U wheel
pip install -r requirements.txt
```

## Running the spider
```bash
scrapy crawl books.toscrape -o books.json
```
This is a spider to scrape books from [http://books.toscrape.com](http://books.toscrape.com).