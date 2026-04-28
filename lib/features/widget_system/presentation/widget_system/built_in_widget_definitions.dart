import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_to_share_widget/dish_to_share_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/image_widget/image_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/set_menu_dish_widget/set_menu_dish_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/set_menu_title_widget/set_menu_title_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/text_widget/text_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/wine_widget/wine_widget_definition.dart';

/// All built-in widget definitions.
///
/// To add a new widget type, add its definition to this list. `AppContainer`
/// reads it lazily to construct the [PresentableWidgetRegistry] used by
/// editor screens.
final List<PresentableWidgetDefinition> allWidgetDefinitions =
    <PresentableWidgetDefinition>[
      dishWidgetDefinition,
      dishToShareWidgetDefinition,
      imageWidgetDefinition,
      sectionWidgetDefinition,
      setMenuDishWidgetDefinition,
      setMenuTitleWidgetDefinition,
      textWidgetDefinition,
      wineWidgetDefinition,
    ];
