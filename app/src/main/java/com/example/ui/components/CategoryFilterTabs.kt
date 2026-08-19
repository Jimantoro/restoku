package com.example.ui.components

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BakeryDining
import androidx.compose.material.icons.filled.Coffee
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.LocalBar
import androidx.compose.material.icons.filled.LunchDining
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.SetMeal
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.CategoryEntity
import com.example.ui.theme.PurplePrimary
import com.example.ui.theme.SurfaceLightChip
import com.example.ui.theme.TextSecondaryLight

@Composable
fun CategoryFilterTabs(
    categories: List<CategoryEntity>,
    selectedCategoryId: Int?,
    onCategorySelected: (Int?) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 16.dp, vertical = 6.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // "Semua Menu" chip
        FilterChip(
            selected = selectedCategoryId == null,
            onClick = { onCategorySelected(null) },
            label = {
                Text(
                    text = "Semua Menu",
                    fontSize = 13.sp,
                    fontWeight = if (selectedCategoryId == null) FontWeight.Bold else FontWeight.Medium
                )
            },
            leadingIcon = {
                Icon(
                    imageVector = Icons.Default.GridView,
                    contentDescription = null,
                    modifier = Modifier.size(16.dp)
                )
            },
            shape = RoundedCornerShape(24.dp),
            border = null,
            colors = FilterChipDefaults.filterChipColors(
                selectedContainerColor = PurplePrimary,
                selectedLabelColor = Color.White,
                selectedLeadingIconColor = Color.White,
                containerColor = SurfaceLightChip,
                labelColor = TextSecondaryLight,
                iconColor = TextSecondaryLight
            ),
            modifier = Modifier.testTag("category_chip_all")
        )

        categories.forEach { category ->
            val isSelected = selectedCategoryId == category.id
            FilterChip(
                selected = isSelected,
                onClick = { onCategorySelected(category.id) },
                label = {
                    Text(
                        text = category.name,
                        fontSize = 13.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                    )
                },
                leadingIcon = {
                    Icon(
                        imageVector = getCategoryIcon(category.iconName),
                        contentDescription = null,
                        modifier = Modifier.size(16.dp)
                    )
                },
                shape = RoundedCornerShape(24.dp),
                border = null,
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = PurplePrimary,
                    selectedLabelColor = Color.White,
                    selectedLeadingIconColor = Color.White,
                    containerColor = SurfaceLightChip,
                    labelColor = TextSecondaryLight,
                    iconColor = TextSecondaryLight
                ),
                modifier = Modifier.testTag("category_chip_${category.id}")
            )
        }
    }
}

private fun getCategoryIcon(iconName: String): ImageVector {
    return when (iconName) {
        "Restaurant" -> Icons.Default.Restaurant
        "LunchDining" -> Icons.Default.LunchDining
        "SetMeal" -> Icons.Default.SetMeal
        "LocalBar" -> Icons.Default.LocalBar
        "Coffee" -> Icons.Default.Coffee
        "BakeryDining" -> Icons.Default.BakeryDining
        else -> Icons.Default.Restaurant
    }
}
