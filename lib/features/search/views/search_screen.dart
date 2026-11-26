import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/location_model.dart';
import '../viewmodels/search_view_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.onLocationSelected});

  final ValueChanged<LocationModel> onLocationSelected;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    context.read<SearchViewModel>().search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Lokasi')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temukan cuaca kota',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF17243B),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cari nama kota, lalu pilih hasil untuk melihat cuacanya.',
                    style: TextStyle(color: Colors.blueGrey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _submitSearch(),
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Makassar',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _submitSearch,
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<SearchViewModel>(
                builder: (context, viewModel, _) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      if (viewModel.favorites.isNotEmpty) ...[
                        _SectionTitle(
                          title: 'Lokasi Favorit',
                          trailing: '${viewModel.favorites.length} tersimpan',
                        ),
                        const SizedBox(height: 8),
                        for (final location in viewModel.favorites)
                          _LocationTile(
                            location: location,
                            isFavorite: true,
                            onTap: () => widget.onLocationSelected(location),
                            onFavoriteTap: () => viewModel.toggleFavorite(location),
                          ),
                        const SizedBox(height: 18),
                      ],
                      if (viewModel.isLoading) ...[
                        const Padding(
                          padding: EdgeInsets.all(26),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ] else if (viewModel.hasSearched &&
                          viewModel.searchResults.isNotEmpty) ...[
                        _SectionTitle(
                          title: 'Hasil Pencarian',
                          trailing: '${viewModel.searchResults.length} lokasi',
                        ),
                        const SizedBox(height: 8),
                        for (final location in viewModel.searchResults)
                          _LocationTile(
                            location: location,
                            isFavorite: viewModel.isFavorite(location),
                            onTap: () => widget.onLocationSelected(location),
                            onFavoriteTap: () => viewModel.toggleFavorite(location),
                          ),
                      ] else if (viewModel.hasSearched &&
                          viewModel.errorMessage != null) ...[
                        _MessagePanel(
                          icon: Icons.location_searching,
                          message: viewModel.errorMessage!,
                        ),
                      ] else if (viewModel.errorMessage != null) ...[
                        _MessagePanel(
                          icon: Icons.info_outline_rounded,
                          message: viewModel.errorMessage!,
                        ),
                      ] else if (viewModel.favorites.isEmpty) ...[
                        const _MessagePanel(
                          icon: Icons.public,
                          message: 'Mulai dengan mencari nama kota di atas.',
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.trailing});
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17243B),
              ),
        ),
        Text(
          trailing,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blueGrey.shade500,
              ),
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFEAF0FF),
          child: Icon(Icons.location_on_outlined, color: Color(0xFF315FCE)),
        ),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          location.subtitle.isEmpty ? 'Lokasi' : location.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
          onPressed: onFavoriteTap,
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? const Color(0xFFE5A000) : Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.blueGrey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade600),
          ),
        ],
      ),
    );
  }
}
