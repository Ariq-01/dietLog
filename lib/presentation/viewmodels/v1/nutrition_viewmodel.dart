import 'package:bitelog/data/models%20v1/chat_messages.dart';
import 'package:flutter/material.dart';
import 'package:bitelog/data/models v1/food_ai_model.dart';
class NutritionViewmodel extends ChangeNotifier{
List<ChatMessages> messages = [];

// DATA STATE
int calories = 0;
int carbs = 0;
int protein = 0;
int fat = 0;


List<FoodResult> foods = [];

// MAIN Action 
Future<void> sendMessages(String input) async {
  // 1. tambahcha user 
  messages.add(ChatMessages(text: input, isUser: true));

  // 2. add loading bubbles 
  messages.add(ChatMessages(text: "Analyzing...", isLoading: true));

  // 3. SIMULATE AI smaple : TO DO : 
  await Future.delayed(Duration(seconds: 2));

  // results from ai tetst mock 
  final result = FoodResult(name: input,
   calories: 240 ,
    carbs: 230,
     protein: 230,
      fat: 232,
      );

      // hapus loading
      messages.removeLast();

      // 6. tambah respons e
      messages.add(ChatMessages(text: "Food Added : ${result.name}"));

      // updates nutriotns 
      foods.add(result);
      calories += result.calories;
      carbs += result.carbs;
      protein += protein;
      fat += fat;

      notifyListeners();


}
}
