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
  final List<String> _searchHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.addAll(prefs.getStringList('search_history') ?? []);
    });
  }

  Future<void> _saveSearchHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(city); // Tránh trùng lặp
    _searchHistory.insert(0, city); // Thêm vào đầu danh sách
    if (_searchHistory.length > 5) _searchHistory.removeLast(); // Giới hạn 5 mục
    await prefs.setStringList('search_history', _searchHistory);
    setState(() {});
  }

  void _onSearch() async {
    final city = _controller.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên thành phố!')),
      );
      return;
    }
    // Regex mới: Chấp nhận chữ cái Latin, tiếng Việt (có dấu), và khoảng trắng
    if (!RegExp(r'^[a-zA-Zàáảãạăắằẳẵặâấầẩẫậèéẹẻẽêềếểễệìíịỉĩòóọỏõôồốổỗộơờớởỡợùúụủũưừứửữựỳýỵỷỹđ\s]+$',
        caseSensitive: false)
        .hasMatch(city)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên thành phố chỉ chứa chữ cái và khoảng trắng!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    await weatherProvider.fetchWeatherByCity(city);
    if (weatherProvider.error == null) {
      await _saveSearchHistory(city);
    }
    setState(() => _isLoading = false);
    Navigator.pop(context); // Quay lại HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm thành phố'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField với gợi ý (Autocomplete)
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _searchHistory;
                }
                return _searchHistory.where((city) => city.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                _controller.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: _controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Nhập tên thành phố',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: _isLoading
                        ? const CircularProgressIndicator()
                        : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _controller.clear(),
                    ),
                  ),
                  onSubmitted: (_) => _onSearch(),
                );
              },
            ),
            const SizedBox(height: 16),
            // Nút tìm kiếm
            ElevatedButton(
              onPressed: _isLoading ? null : _onSearch,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tìm kiếm', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            // Hiển thị lỗi hoặc lịch sử
            if (weatherProvider.error != null)
              Text(
                weatherProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_searchHistory.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    final city = _searchHistory[index];
                    return ListTile(
                      title: Text(city),
                      onTap: () {
                        _controller.text = city;
                        _onSearch();
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _searchHistory.removeAt(index);
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setStringList('search_history', _searchHistory);
                            });
                          });
                        },
                      ),
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