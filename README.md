# space-maps-dem-converter
- Downloads map tiles from grayscale Digital Elevation Map of Mars, using NASA's Trek API https://api.nasa.gov/api.html#trek
- Analyzes the images to find grayscale value, and exports json which can be used to build an elevation map.
- Resolution can be changed in the code.


### Setup
1. Download the tiles `ruby code/dem-dl.rb`
2. Analyze the image and output json `ruby code/elevation_calculator.rb`


### Example json output/format
```
[
  {
    "planet":"mars",
    "max_rows":32,
    "max_cols":64,
    "tiles":[
      {
        "row":0,
        "col":0,
        "pixels":[
          0.19362897242955987,
          0.19375009462671652,
          0.15685324531787007,
          0.15980559887356358
        ]
      },
      {
        "row":0,
        "col":1,
        "pixels":[
          0.19375009462671652,
          0.19371981407742736,
          0.1608654180986843,
          0.16075943617617225
        ]
      }
    ]
  }
]
```
