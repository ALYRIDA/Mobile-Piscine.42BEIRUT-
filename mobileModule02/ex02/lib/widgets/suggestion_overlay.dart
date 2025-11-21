import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/country.dart';

class SuggestionOverlay extends StatelessWidget {
  final List<City> citySuggestions;
  final List<Country> countrySuggestions;
  final bool isLoading;
  final Function(City) onCitySelected;
  final Function(Country) onCountrySelected;
  final double width;
  final String searchQuery;

  const SuggestionOverlay({
    super.key,
    required this.citySuggestions,
    required this.countrySuggestions,
    required this.isLoading,
    required this.onCitySelected,
    required this.onCountrySelected,
    required this.width,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        color: Colors.grey[900],
        constraints: const BoxConstraints(maxHeight: 300),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (searchQuery.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Start typing to search cities or countries',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return _buildSearchSuggestions();
  }

  Widget _buildSearchSuggestions() {
    final hasCities = citySuggestions.isNotEmpty;
    final hasCountries = countrySuggestions.isNotEmpty;

    if (!hasCities && !hasCountries) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No results found',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: [
        if (hasCountries) ...[
          _buildSectionHeader('🌍 Countries starting with "$searchQuery"'),
          ...countrySuggestions.take(5).map((country) => ListTile(
                leading: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 20),
                ),
                title: _buildHighlightedText(country.name, searchQuery),
                subtitle: const Text(
                  'Country',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () => onCountrySelected(country),
              )),
        ],
        if (hasCities) ...[
          if (hasCountries) const Divider(height: 1, color: Colors.white24),
          _buildSectionHeader('🏙️ Cities starting with "$searchQuery"'),
          ...citySuggestions.take(5).map((city) => ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: _buildHighlightedText(city.name, searchQuery),
                subtitle: Text(
                  '${city.region}, ${city.country}',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () => onCitySelected(city),
              )),
        ],
      ],
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(text, style: const TextStyle(color: Colors.white));
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(text, style: const TextStyle(color: Colors.white));
    }

    final beforeMatch = text.substring(0, matchIndex);
    final match = text.substring(matchIndex, matchIndex + query.length);
    final afterMatch = text.substring(matchIndex + query.length);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: beforeMatch,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: match,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: afterMatch,
            style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
