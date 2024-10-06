import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netflix_clone/pages/detail_page.dart';
import 'package:http/http.dart' as http;
import 'package:netflix_clone/utils/colors.dart';

class MoviesPage extends StatefulWidget {
  final PageController homePageController;
  const MoviesPage({super.key, required this.homePageController});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> with AutomaticKeepAliveClientMixin {
  bool _loading = false;
  String selectedStatus = 'Relevance';
  final List<String> _sortOptions = ['Relevance', 'Most popular', 'Highest Rated'];
  List<dynamic> movies = [];

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
      Uri.parse('https://api.tvmaze.com/search/shows?q=the'),
    );
    if (response.statusCode == 200) {
      setState(() {
        movies = json.decode(response.body);
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
                    childAspectRatio: 0.6,
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
  List<String> genre = [''];
  @override
  void initState() {
    poster = (widget.movie['show']['image'] != null) ? widget.movie['show']['image']['medium'] : '';
    name = widget.movie['show']['name'] ?? '';
    year = widget.movie['show']['premiered'] ?? 'Year ';
    if (widget.movie['show']['genres'] != null) {
      genre = widget.movie['show']['genres'].length > 0 ? List<String>.from(widget.movie['show']['genres']) : ['Other'];
    }
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
                  image: (poster != '') ? NetworkImage(poster) : const AssetImage('assets/default_movie.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              color: colorScheme.inversePrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${year.substring(0, 4)} • ${genre[0]}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
