enum PlayerStatus {
  idle,       // Ничего не загружено
  loading,    // Загружаем трек
  playing,    // Играет
  paused,     // Есть трек, но стоит на паузе
  completed,  // Трек закончился
  error,      // Произошла ошибка
}