import 'package:flutter/material.dart';

// Модель данных продукта
class Product { //простая класс-  для хранения данных о товаре
  final int id; //финал ознают что ссылка не будет меняться после создания объекта
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({  //конструктор,создает продукт
    //требует эти поля при создании
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });
}

// Набор демонстрационных продуктов
final List<Product> demoProducts = [
  Product(
    id: 1,
    title: 'Яблоко',
    description: 'Свежее красное яблоко, хрустящее и сочное.',
    price: 1.50,
    imageUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=400&q=60',
  ),
  Product(
    id: 2,
    title: 'Банан',
    description: 'Спелые бананы — отличный перекус.',
    price: 0.99,
    imageUrl: 'https://images.unsplash.com/photo-1574226516831-e2923d3eea11?auto=format&fit=crop&w=400&q=60',
  ),
  Product(
    id: 3,
    title: 'Апельсин',
    description: 'Сочные апельсины, богаты витамином C.',
    price: 1.20,
    imageUrl: 'https://images.unsplash.com/photo-1502741126161-b048400d36f6?auto=format&fit=crop&w=400&q=60',
  ),
  Product(
    id: 4,
    title: 'Груша',
    description: 'Сладкая груша — мягкая и ароматная.',
    price: 1.30,
    imageUrl: 'https://images.unsplash.com/photo-1519183071298-a2962be54a00?auto=format&fit=crop&w=400&q=60',
  ),
  Product(
    id: 5,
    title: 'Виноград',
    description: 'Гроздь сочного винограда, отлично для перекуса.',
    price: 2.50,
    imageUrl: 'https://images.unsplash.com/photo-1514519884887-0b9b2c1a61b5?auto=format&fit=crop&w=400&q=60',
  ),
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Каталог продуктов',
      debugShowCheckedModeBanner: false,//убирает баг лента
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

// Главная страница с табами (Каталог и Избранное)
class HomePage extends StatefulWidget {//StatefulWidget-есть изменяемое состояние
  @override //переопределяем 
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // состояние: список продуктов (копия demo)
  List<Product> products = demoProducts.map((p) => Product(
    id: p.id,
    title: p.title,
    description: p.description,
    price: p.price,
    imageUrl: p.imageUrl,
    isFavorite: p.isFavorite,
  )).toList();

  // корзина: Map productId -> quantity
  Map<int, int> cart = {};//так проще считать кол и стои 

  // текущий индекс нижней навигации: 0 = каталог, 1 = избранное
  int _currentIndex = 0;

  // строка поиска
  String _searchQuery = '';

  // фильтрованный список по поиску и по табу
  List<Product> get filteredProducts {
    final query = _searchQuery.toLowerCase();
    final base = products.where((p) => p.title.toLowerCase().contains(query) || p.description.toLowerCase().contains(query));
    if (_currentIndex == 1) { // вкладка "Избранное"
      return base.where((p) => p.isFavorite).toList();
    }
    return base.toList(); // вкладка "Каталог"
  }

  // добавление в корзину
  void addToCart(Product product) {
    setState(() { //сетстейт обновление стр
      cart.update(product.id, (value) => value + 1, ifAbsent: () => 1);
    });

    // короткое уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.title} добавлен(а) в корзину')),
    );
  }

  // удаление одного экземпляра из корзины
  void removeOneFromCart(Product product) {
    setState(() {
      if (!cart.containsKey(product.id)) return;
      final current = cart[product.id]!;
      if (current <= 1) cart.remove(product.id);
      else cart[product.id] = current - 1;
    });
  }

  // общий подсчёт количества товаров в корзине
  int get totalCartItems => cart.values.fold(0, (a, b) => a + b);

  // суммарная стоимость
  double get cartTotalPrice {
    double sum = 0.0;
    cart.forEach((productId, qty) {
      final product = products.firstWhere((p) => p.id == productId, orElse: () => Product(
        id: 0, title: 'Unknown', description: '', price: 0.0, imageUrl: '',
      ));
      sum += product.price * qty;
    });
    return sum;
  }

  // переключение состояния "избранное"
  void toggleFavorite(Product product) {
    setState(() {
      final idx = products.indexWhere((p) => p.id == product.id);
      if (idx != -1) products[idx].isFavorite = !products[idx].isFavorite;
    });
  }

  // переход на страницу деталей
  void openDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          product: product,
          onAddToCart: () => addToCart(product),
          onToggleFavorite: () => toggleFavorite(product),
        ),
      ),
    );
  }

  // открыть корзину (новая страница)
  void openCartPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartPage(
          products: products,
          cart: cart,
          onRemoveOne: (p) => removeOneFromCart(p),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Каталог продуктов'),
        actions: [
          // значок корзины с бейджем количества
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: openCartPage,
              ),
              if (totalCartItems > 0)
                Positioned(
                  right: 6,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalCartItems',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Поиск по названию или описанию',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: filteredProducts.isEmpty
          ? Center(child: Text('Ничего не найдено'))
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () => openDetails(product),
                  onAddToCart: () => addToCart(product),
                  onToggleFavorite: () => toggleFavorite(product),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Каталог'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
        ],
        onTap: (idx) => setState(() {
          _currentIndex = idx;
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCartPage,
        child: Icon(Icons.shopping_basket),
      ),
    );
  }
}

// Карточка продукта в списке
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Изображение
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              // Текстовая часть
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                        Spacer(),
                        IconButton(
                          icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                          onPressed: onToggleFavorite,
                        ),
                        ElevatedButton(
                          onPressed: onAddToCart,
                          child: Text('В корзину'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Страница деталей продукта
class ProductDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.onAddToCart,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          IconButton(
            icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: onToggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(product.imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(product.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
                ],
              ),
              SizedBox(height: 12),
              Text(product.description),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    onAddToCart();
                    // Дополнительно — вернуться на предыдущий экран или оставить
                    // Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Добавить в корзину'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Страница корзины
class CartPage extends StatelessWidget {
  final List<Product> products;
  final Map<int, int> cart;
  final void Function(Product) onRemoveOne;

  const CartPage({
    Key? key,
    required this.products,
    required this.cart,
    required this.onRemoveOne,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Собираем список пар (Product, qty)
    final items = cart.entries.map((e) {
      final product = products.firstWhere((p) => p.id == e.key, orElse: () => Product(id: 0, title: 'Unknown', description: '', price: 0.0, imageUrl: ''));
      return MapEntry(product, e.value);
    }).toList();

    double total = items.fold(0.0, (sum, pair) => sum + pair.key.price * pair.value);

    return Scaffold(
      appBar: AppBar(title: Text('Корзина')),
      body: items.isEmpty
          ? Center(child: Text('Корзина пуста'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final product = items[idx].key;
                        final qty = items[idx].value;
                        return ListTile(
                          leading: Image.network(product.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                          title: Text(product.title),
                          subtitle: Text('Цена: \$${product.price.toStringAsFixed(2)}  •  Кол-во: $qty'),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () => onRemoveOne(product),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Итого:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Простая имитация оформления заказа
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Заказ оформлен (демо)')));
                      },
                      child: Text('Оформить заказ'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
