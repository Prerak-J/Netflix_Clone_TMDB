import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:netflix_clone/main.dart';
import 'package:netflix_clone/utils/constants.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final dynamic movie;
  const DetailPage({super.key, this.movie});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String poster = '';
  String backdropImg = '';
  String name = '';
  String year = '';
  String lang = '';
  String description = '';
  String rating = '-';
  List<int> genreList = [-1];
  List<String> genre = ['Unknown'];
  String imagePath = 'http://image.tmdb.org/t/p/w500';

  Widget posterImage = Container();
  @override
  void initState() {
    poster = (widget.movie['poster_path'] != null) ? widget.movie['poster_path'] : '';
    backdropImg = (widget.movie['backdrop_path'] != null) ? widget.movie['backdrop_path'] : '';
    name = widget.movie['original_title'] ?? '';

    //YEAR
    year = widget.movie['release_date'] ?? 'Unknown';
    if (year.length < 4) {
      year = 'Unknown';
    }

    //GENRE
    if (widget.movie['genre_ids'] != null) {
      genreList = widget.movie['genre_ids'].length > 0 ? List<int>.from(widget.movie['genre_ids']) : [-1];
    }
    genre = List.generate(genreList.length, (i) => genresMap[genreList[i]] ?? 'Unknown');

    //LANGUAGE
    lang = (widget.movie['original_language'] != null) ? '${widget.movie['original_language']}' : '';
    switch (lang) {
      case 'en':
        lang = 'English';
        break;
      default:
        lang.toUpperCase();
        break;
    }

    //RATING
    {
      num ratingNum = (widget.movie['vote_average'] != null) ? widget.movie['vote_average'] ?? 0.0 : 0.0;
      rating = ratingNum.toStringAsFixed(1);
    }

    //SUMMARY
    {
      description = widget.movie['overview'] ?? '';
      final doc = parse(description);
      description = parse(doc.body!.text).documentElement!.text;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    //POSTER
    posterImage = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: 400,
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: (poster != '') ? NetworkImage(imagePath + poster) : const AssetImage('assets/default_movie.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.tertiary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: colorScheme.inversePrimary,
            size: 30,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      backdropImg != ''
                          ? Image.network(
                              imagePath + backdropImg,
                              fit: BoxFit.cover,
                              height: 400,
                              width: double.infinity,
                            )
                          : Image.asset(
                              'assets/default_movie.png',
                              fit: BoxFit.fill,
                              height: 400,
                              width: double.infinity,
                            ),
                      posterImage,
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 80, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          softWrap: true,
                          name,
                          style: TextStyle(
                            color: colorScheme.inversePrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            rating == '0.0' ? '-' : rating,
                            style: TextStyle(
                              color: colorScheme.inversePrimary,
                              fontSize: 20,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Icon(
                              Icons.star_rate,
                              color: Colors.amberAccent,
                              size: 22,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Text(
                    '${year == 'Unknown' ? 'Unknown' : year} | ${genre.join(', ')}',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                  child: Text(
                    'Language: $lang',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark ? Colors.white70 : Colors.black87,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark ? Colors.white70 : Colors.black,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
