package com.example.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.BakeryDining
import androidx.compose.material.icons.filled.Coffee
import androidx.compose.material.icons.filled.EditNote
import androidx.compose.material.icons.filled.LocalBar
import androidx.compose.material.icons.filled.LunchDining
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.SetMeal
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.CartItem
import com.example.data.model.MenuEntity
import com.example.data.repository.RestaurantRepository
import com.example.ui.theme.ErrorRed
import com.example.ui.theme.PurpleOnPrimaryContainer
import com.example.ui.theme.PurplePrimary
import com.example.ui.theme.PurplePrimaryContainer
import com.example.ui.theme.SuccessGreen
import com.example.ui.theme.SurfaceLightBorder

@Composable
fun MenuCard(
    menu: MenuEntity,
    cartItem: CartItem?,
    onAddToCart: () -> Unit,
    onQuantityChange: (Int) -> Unit,
    onOpenNotes: (CartItem) -> Unit,
    modifier: Modifier = Modifier
) {
    val isOutOfStock = menu.stock <= 0
    val inCartQty = cartItem?.quantity ?: 0

    Card(
        modifier = modifier
            .fillMaxWidth()
            .testTag("menu_card_${menu.id}")
            .alpha(if (isOutOfStock) 0.6f else 1.0f),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
        border = if (inCartQty > 0) androidx.compose.foundation.BorderStroke(1.5.dp, PurplePrimary)
        else androidx.compose.foundation.BorderStroke(1.dp, SurfaceLightBorder.copy(alpha = 0.5f))
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp)
        ) {
            // Icon thumbnail + stock badge
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(42.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(PurplePrimaryContainer),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = getMenuIcon(menu.categoryName),
                        contentDescription = menu.categoryName,
                        tint = PurpleOnPrimaryContainer,
                        modifier = Modifier.size(22.dp)
                    )
                }

                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = if (isOutOfStock) ErrorRed.copy(alpha = 0.12f) else SuccessGreen.copy(alpha = 0.12f)
                ) {
                    Text(
                        text = if (isOutOfStock) "Habis" else "Stok: ${menu.stock}",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = if (isOutOfStock) ErrorRed else SuccessGreen,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Menu title
            Text(
                text = menu.name,
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            if (menu.description.isNotBlank()) {
                Spacer(modifier = Modifier.height(3.dp))
                Text(
                    text = menu.description,
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    lineHeight = 16.sp
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Price and Action controls
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = RestaurantRepository.formatRupiah(menu.price),
                    fontSize = 15.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color = PurplePrimary
                )

                if (inCartQty > 0) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        // Notes button
                        Box(
                            modifier = Modifier
                                .size(30.dp)
                                .clip(CircleShape)
                                .background(
                                    if (!cartItem?.notes.isNullOrBlank()) PurplePrimary.copy(alpha = 0.2f)
                                    else MaterialTheme.colorScheme.surfaceVariant
                                )
                                .clickable { cartItem?.let { onOpenNotes(it) } },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.EditNote,
                                contentDescription = "Catatan",
                                tint = if (!cartItem?.notes.isNullOrBlank()) PurplePrimary else MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.size(16.dp)
                            )
                        }

                        // Minus
                        FilledTonalIconButton(
                            onClick = { onQuantityChange(inCartQty - 1) },
                            modifier = Modifier.size(30.dp),
                            shape = CircleShape,
                            colors = IconButtonDefaults.filledTonalIconButtonColors(
                                containerColor = MaterialTheme.colorScheme.surfaceVariant
                            )
                        ) {
                            Icon(
                                imageVector = Icons.Default.Remove,
                                contentDescription = "Kurang",
                                modifier = Modifier.size(14.dp)
                            )
                        }

                        Text(
                            text = inCartQty.toString(),
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 4.dp)
                        )

                        // Plus
                        FilledTonalIconButton(
                            onClick = { onQuantityChange(inCartQty + 1) },
                            modifier = Modifier.size(30.dp),
                            shape = CircleShape,
                            enabled = inCartQty < menu.stock,
                            colors = IconButtonDefaults.filledTonalIconButtonColors(
                                containerColor = PurplePrimary,
                                contentColor = Color.White
                            )
                        ) {
                            Icon(
                                imageVector = Icons.Default.Add,
                                contentDescription = "Tambah",
                                modifier = Modifier.size(14.dp)
                            )
                        }
                    }
                } else {
                    Surface(
                        onClick = onAddToCart,
                        enabled = !isOutOfStock,
                        shape = RoundedCornerShape(12.dp),
                        color = if (isOutOfStock) MaterialTheme.colorScheme.surfaceVariant else PurplePrimary,
                        modifier = Modifier.testTag("add_button_${menu.id}")
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.Add,
                                contentDescription = null,
                                tint = if (isOutOfStock) MaterialTheme.colorScheme.onSurfaceVariant else Color.White,
                                modifier = Modifier.size(15.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "Pesan",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isOutOfStock) MaterialTheme.colorScheme.onSurfaceVariant else Color.White
                            )
                        }
                    }
                }
            }

            // Show active note indicator if any
            if (!cartItem?.notes.isNullOrBlank()) {
                Spacer(modifier = Modifier.height(6.dp))
                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = PurplePrimaryContainer.copy(alpha = 0.5f),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = "📝 ${cartItem?.notes}",
                        fontSize = 11.sp,
                        color = PurpleOnPrimaryContainer,
                        fontWeight = FontWeight.Medium,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}

private fun getMenuIcon(categoryName: String): ImageVector {
    return when {
        categoryName.contains("Minum", ignoreCase = true) || categoryName.contains("Teh", ignoreCase = true) || categoryName.contains("Kopi", ignoreCase = true) -> Icons.Default.LocalBar
        categoryName.contains("Snack", ignoreCase = true) || categoryName.contains("Camilan", ignoreCase = true) || categoryName.contains("Pisang", ignoreCase = true) -> Icons.Default.BakeryDining
        categoryName.contains("Ikan", ignoreCase = true) || categoryName.contains("Laut", ignoreCase = true) -> Icons.Default.SetMeal
        categoryName.contains("Nasi", ignoreCase = true) || categoryName.contains("Ayam", ignoreCase = true) || categoryName.contains("Goreng", ignoreCase = true) -> Icons.Default.LunchDining
        else -> Icons.Default.Restaurant
    }
}
