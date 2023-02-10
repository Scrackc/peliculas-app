import 'package:flutter/material.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final Movie movie = ModalRoute.of(context)!.settings.arguments as Movie;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _CustomAppBar(bgPath: movie.fullBackdropPath, title: movie.title,),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _PosterAndTitle(
                  image: movie.fullPosterImg,
                  title: movie.title,
                  originalTitle: movie.originalTitle,
                  voteAverage: movie.voteAverage.toString(), movieId: movie.heroId!,
                ),
                _Overview(movie.overview),
                CastingCards( movie.id )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final String title;
  final String bgPath;
  const _CustomAppBar({required this.title, required this.bgPath});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.all(0),
        stretchModes: const [StretchMode.blurBackground],
        centerTitle: true,
        title: Container(
          width: double.infinity,
          color: Colors.black12,
          padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
          alignment: Alignment.bottomCenter,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        background: FadeInImage(
          placeholder: const AssetImage('assets/loading.gif'),
          image: NetworkImage(bgPath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _PosterAndTitle extends StatelessWidget {
  final String image;
  final String title;
  final String originalTitle;
  final String voteAverage;
  final String movieId;

  const _PosterAndTitle({ required this.image, required this.title, required this.originalTitle, required this.voteAverage, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Hero(
            tag: movieId,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FadeInImage(
                placeholder: const AssetImage('assets/no-image.jpg'),
                image: NetworkImage(image),
                height: 150,
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                title,
                style: textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                ),
                
                Text(
                  originalTitle,
                  style: textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star_border_outlined,
                      size: 15,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      voteAverage,
                      style: textTheme.bodySmall,
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  final String overview;
  const _Overview(this.overview);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(overview, textAlign: TextAlign.justify, style: Theme.of(context).textTheme.titleMedium,),
    );
  }
}