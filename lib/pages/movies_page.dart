import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netflix_clone/pages/detail_page.dart';
import 'package:http/http.dart' as http;
import 'package:netflix_clone/utils/colors.dart';
import 'package:netflix_clone/utils/constants.dart';

class MoviesPage extends StatefulWidget {
  final PageController homePageController;
  const MoviesPage({super.key, required this.homePageController});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> with AutomaticKeepAliveClientMixin {
  bool _loading = false;
  String selectedStatus = 'Most Popular';
  final List<String> _sortOptions = ['Most Popular', 'Highest Rated'];
  List<dynamic> movies = [];
  String popularApi =
      'https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc&api_key=e35c24dd8bae89146b08b893d01e719d';

  String highRatedApi =
      'https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=vote_average.desc&api_key=e35c24dd8bae89146b08b893d01e719d';

  @override
  void initState() {
    fetchMovies();
    super.initState();
  }

  Future<void> fetchMovies() async {
    setState(() {
      _loading = true;
    });
    final response = await http.get(
      Uri.parse(selectedStatus == 'Highest Rated' ? highRatedApi : popularApi),
    );
    if (response.statusCode == 200) {
      setState(() {
        var moviesMap = json.decode(response.body);
        movies = List.from(moviesMap['results']);
      });
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => const Dialog(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text('ERROR FETCHING MOVIES'),
                ),
              ),
            ),
          ),
        );
      }
      throw Exception('Failed to load movies');
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _loading
        ? Container(
            alignment: Alignment.center,
            color: colorScheme.primary,
            child: const CircularProgressIndicator(
              color: Colors.redAccent,
            ),
          )
        : Container(
            padding: const EdgeInsets.all(8.0),
            color: colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  forceMaterialTransparency: true,
                  backgroundColor: colorScheme.secondary,
                  automaticallyImplyLeading: false,
                  leading: null,
                  leadingWidth: 0.0,
                  floating: true,
                  flexibleSpace: InkWell(
                    onTap: () => widget.homePageController.jumpToPage(1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.4,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.secondary,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: colorScheme.inversePrimary,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Text(
                            'Search Movies, TV Series...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              wordSpacing: 0.5,
                              letterSpacing: 0.3,
                              color: colorScheme.inversePrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 4, 16),
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            selectedStatus = value;
                            fetchMovies();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: deepRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sort By: $selectedStatus ',
                                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                        itemBuilder: (BuildContext context) {
                          return _sortOptions.map((String option) {
                            return PopupMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
                SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 40,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    return MovieCard(movie: movies[index]);
                  },
                )
              ],
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
}

class MovieCard extends StatefulWidget {
  final dynamic movie;

  const MovieCard({super.key, required this.movie});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  String poster = '', name = '', year = '';
  List<int> genreList = [-1];
  String genre = 'Unknown';
  String imagePath = 'http://image.tmdb.org/t/p/w500';
  @override
  void initState() {
    poster = (widget.movie['poster_path'] != null) ? widget.movie['poster_path'] : '';
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
    genre = genresMap[genreList[0]] ?? 'Unknown';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(movie: widget.movie),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image:
                      (poster != '') ? NetworkImage(imagePath + poster) : const AssetImage('assets/default_movie.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              color: colorScheme.inversePrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${year == 'Unknown' ? 'Unknown' : year.substring(0, 4)} • $genre',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
