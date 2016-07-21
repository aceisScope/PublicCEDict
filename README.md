PublicCEDict
============

This is an Objective-C version of Chinese-English dictionary based on the open-source CC-CEDICT. 
The dictionary it bases on is the same (or almost the same) as Pleco.

![ScreenShot](https://raw.github.com/aceisScope/PublicCEDict/master/screenshots/screenshot.png)

## Description ##

The dictionary resource is the Creative Commons licensed Chinese-English dictionary [CC-CEDICT](http://www.mdbg.net/chindict/chindict.php?page=cedict).
When creating/querying the database of CEDICT, I use the brilliant [FMDB](https://github.com/ccgus/fmdb) of August Mueller and [LineReader](https://github.com/johnjohndoe/LineReader) of Tobias Preuss which is originally written by [Dave DeLong](https://github.com/davedelong).

## Resources ##

My first intention was to use Trie structure for string search, which failed after I tried to store more than 100,000 items into an [NDTrie](https://github.com/nathanday/ndtrie) by [Nathan Day](https://github.com/nathanday), because the time and memory expense is far from ideal. 
So I turned to normal sqlite database. 

The original CC-CEDICT is a text file, so what I did is simply transferring it into a cedict.db3 and doing relative queries with SQL.
All this project about is an available Chinese-English database, providing **Traditional Chinese**, **Simplified Chinese**, **Pinyin** and **English definitions**.
