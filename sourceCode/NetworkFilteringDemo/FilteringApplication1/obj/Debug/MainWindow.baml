   M S B A M L   `   `   `  ����  FilteringApplication1&     FilteringApplication1.MainWindow   5   	   R NWindowsBase, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5      8x,http://schemas.microsoft.com/winfx/2006/xaml    5        � Title$  Window1��5      $	��300��6   $	��610��6"    � 	Resources 5       �� MergedDictionaries �� Source�� 5   
    5      �� 5      $ Templates.xaml?�6%   %    5
      .��5      � $	��600��6    � ColumnDefinitions 5   
   �� 5      $	��300 �6   6-   �� 5      $	��300 �6   6-    � RowDefinitions 5   
   �� 5      $��50 �6   �� 5      .+�5   
   �� -   5         ��Name$ 	leftLabel��5   \   $��0��6   $��0��6"   $��Left Bin��6/   $��Center=�6?   6\   �� 5   
   -   5        $ 
rightLabel��5   ]   $��1��6   $��0��6"   $��	Right Bin��6/   $��Center=�6@   6]   �� 5   
   -   5         ��Name$ leftBin��5   /   $��1��6   $��0��6      transactionTemplate#��[  5      ��5      �� *	LeftBin+��5      �� 5      .R�5      $�  K� IsItemsHost . 6-   5       5#      �� 5%   
   -   5        $ rightBin��5%   /   $��1��6   $��1��6   #��[  5'      ��5&      �� *
RightBin+��5(      �� 5)      .R�5*      $�  . 6-   5+      5-      5/      50      