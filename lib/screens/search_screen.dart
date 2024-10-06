import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netflix_clone/pages/detail_page.dart';
import 'package:netflix_clone/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:netflix_clone/utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  String searchTerm = '';
  String searchApi =
      'https://api.themoviedb.org/3/search/movie?query={searchTerm}&include_adult=false&language=en-US&page=1&api_key=e35c24dd8bae89146b08b893d01e719d';

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
      Uri.parse(
        searchApi.replaceFirst(RegExp(r'{searchTerm}'), searchTerm),
      ),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            color: colorScheme.primary,
            padding: const EdgeInsets.all(8.0),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  forceMaterialTransparency: true,
                  backgroundColor: secondaryBlack,
                  automaticallyImplyLeading: false,
                  leading: null,
                  leadingWidth: 0.0,
                  floating: true,
                  flexibleSpace: Container(
                    alignment: Alignment.center,
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
                    child: TextField(
                      onSubmitted: (value) => setState(() {
                        searchTerm = _searchController.text;
                        fetchMovies();
                      }),
                      maxLines: 1,
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: colorScheme.inversePrimary,
                      style: TextStyle(
                        color: colorScheme.inversePrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search Movies, TV Series...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.only(bottom: 10),
                        icon: Icon(
                          Icons.search_rounded,
                          color: colorScheme.inversePrimary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                movies.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            searchTerm == '' ? 'Please enter a movie name' : 'Oops, no such movie found!',
                            style: TextStyle(
                              color: colorScheme.inversePrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SliverGrid.builder(
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
                      ),
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
