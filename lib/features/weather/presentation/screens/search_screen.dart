// lib/screens/search_screen.dart

import 'dart:async'; // Cần cho Timer (debouncing)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/weather_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _searchHistory = [];
  List<String> _apiSuggestions = [];
  bool _isSearching = false; // Dùng khi bấm nút tìm kiếm chính
  bool _isFetchingSuggestions = false; // Dùng khi đang lấy gợi ý
  Timer? _debounce; // Biến để quản lý debouncing

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel(); // Hủy timer khi widget bị hủy
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    // Chuẩn hóa tên thành phố trước khi lưu
    final standardizedCity = city.split(',').first.trim();
    if (_searchHistory.contains(standardizedCity)) {
      _searchHistory.remove(standardizedCity);
    }
    _searchHistory.insert(0, standardizedCity);
    if (_searchHistory.length > 5) _searchHistory.removeLast();
    await prefs.setStringList('search_history', _searchHistory);
    setState(() {});
  }

  // Hàm xử lý khi người dùng nhập text, có debouncing
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 2) {
        setState(() {
          _apiSuggestions = [];
          _isFetchingSuggestions = false;
        });
        return;
      }

      setState(() {
        _isFetchingSuggestions = true;
      });

      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final suggestions = await weatherProvider.fetchCitySuggestions(query);

      setState(() {
        _apiSuggestions = suggestions;
        _isFetchingSuggestions = false;
      });
    });
  }

  void _performSearch(String city) async {
    // Tách lấy tên thành phố (phần trước dấu phẩy)
    final cityName = city.split(',').first.trim();

    if (cityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên thành phố!')),
      );
      return;
    }

    setState(() => _isSearching = true);

    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final weather = await weatherProvider.fetchWeatherByCity(cityName);

    setState(() => _isSearching = false);

    if (weather != null && weatherProvider.error == null) {
      await _saveSearchHistory(cityName);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    // Kết hợp lịch sử và gợi ý API (loại bỏ trùng lặp)
    final combinedSuggestions = {
      ..._apiSuggestions,
      ..._searchHistory.where((h) => h.toLowerCase().contains(_controller.text.toLowerCase()))
    }.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm thành phố'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Nhập tên thành phố ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _apiSuggestions = [];
                    });
                  },
                )
                    : const Icon(Icons.search),
              ),
              onSubmitted: (_) => _performSearch(_controller.text),
            ),
            const SizedBox(height: 10),
            if (_isSearching) const LinearProgressIndicator(),

            // HIỂN THỊ GỢI Ý VÀ LỊCH SỬ
            Expanded(
              child: _buildSuggestionList(weatherProvider, combinedSuggestions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionList(WeatherProvider weatherProvider, List<String> suggestions) {
    // 1. Khi đang tải API
    if (_isFetchingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }
    // 2. Hiển thị lỗi từ provider
    if (weatherProvider.error != null && !_isSearching) {
      return Center(child: Text(weatherProvider.error!, style: const TextStyle(color: Colors.red)));
    }
    // 3. Khi người dùng chưa nhập gì, hiển thị lịch sử
    if (_controller.text.isEmpty && _searchHistory.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lịch sử tìm kiếm', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: _buildHistoryList(weatherProvider)),
        ],
      );
    }
    // 4. Hiển thị danh sách gợi ý kết hợp
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.location_city),
          title: Text(suggestion),
          onTap: () {
            _controller.text = suggestion;
            _performSearch(suggestion);
          },
        );
      },
    );
  }

  // Widget riêng để hiển thị lịch sử (giống code cũ của bạn)
  Widget _buildHistoryList(WeatherProvider weatherProvider) {
    return ListView.builder(
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final city = _searchHistory[index];
        return ListTile(
          title: Text(city),
          leading: const Icon(Icons.history),
          onTap: () {
            _controller.text = city;
            _performSearch(city);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: () async {
              final removedCity = _searchHistory[index];
              setState(() {
                _searchHistory.removeAt(index);
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('search_history', _searchHistory);
              // Xóa khỏi danh sách thành phố đã lưu nếu cần
              // await weatherProvider.removeCityFromList(removedCity);
            },
          ),
        );
      },
    );
  }
}