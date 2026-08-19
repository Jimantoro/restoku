package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Assessment
import androidx.compose.material.icons.filled.PointOfSale
import androidx.compose.material.icons.filled.ReceiptLong
import androidx.compose.material.icons.filled.RestaurantMenu
import androidx.compose.material.icons.filled.TableBar
import androidx.compose.material.icons.outlined.Assessment
import androidx.compose.material.icons.outlined.PointOfSale
import androidx.compose.material.icons.outlined.ReceiptLong
import androidx.compose.material.icons.outlined.RestaurantMenu
import androidx.compose.material.icons.outlined.TableBar
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.data.database.AppDatabase
import com.example.data.repository.RestaurantRepository
import com.example.ui.components.PaymentModal
import com.example.ui.components.ReceiptModal
import com.example.ui.screens.MenuManagementScreen
import com.example.ui.screens.PosScreen
import com.example.ui.screens.ReportScreen
import com.example.ui.screens.TableScreen
import com.example.ui.screens.TransactionHistoryScreen
import com.example.ui.theme.AmberPrimary
import com.example.ui.theme.MyApplicationTheme
import com.example.ui.viewmodel.AppNavTab
import com.example.ui.viewmodel.RestaurantViewModel
import com.example.ui.viewmodel.RestaurantViewModelFactory
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

class MainActivity : ComponentActivity() {

    private val applicationScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    private val database by lazy {
        AppDatabase.getDatabase(this, applicationScope)
    }

    private val repository by lazy {
        RestaurantRepository(database)
    }

    private val viewModel: RestaurantViewModel by viewModels {
        RestaurantViewModelFactory(repository)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                MainAppContent(viewModel = viewModel)
            }
        }
    }
}

@Composable
fun MainAppContent(viewModel: RestaurantViewModel) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val categories by viewModel.categories.collectAsStateWithLifecycle()
    val filteredMenus by viewModel.filteredMenus.collectAsStateWithLifecycle()
    val tables by viewModel.tables.collectAsStateWithLifecycle()
    val orders by viewModel.orders.collectAsStateWithLifecycle()

    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(uiState.notificationMessage) {
        uiState.notificationMessage?.let { msg ->
            snackbarHostState.showSnackbar(msg)
            viewModel.clearNotification()
        }
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        snackbarHost = { SnackbarHost(snackbarHostState) },
        bottomBar = {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.surface,
                tonalElevation = 6.dp
            ) {
                NavigationBarItem(
                    selected = uiState.currentTab == AppNavTab.POS_CASHIER,
                    onClick = { viewModel.setTab(AppNavTab.POS_CASHIER) },
                    icon = {
                        Icon(
                            imageVector = if (uiState.currentTab == AppNavTab.POS_CASHIER) Icons.Filled.PointOfSale else Icons.Outlined.PointOfSale,
                            contentDescription = "Kasir",
                            modifier = Modifier.size(22.dp)
                        )
                    },
                    label = { Text("Kasir", fontSize = 11.sp, fontWeight = FontWeight.SemiBold) },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = AmberPrimary,
                        selectedTextColor = AmberPrimary,
                        indicatorColor = com.example.ui.theme.PurpleSecondaryContainer
                    ),
                    modifier = Modifier.testTag("nav_pos")
                )

                NavigationBarItem(
                    selected = uiState.currentTab == AppNavTab.TABLES,
                    onClick = { viewModel.setTab(AppNavTab.TABLES) },
                    icon = {
                        Icon(
                            imageVector = if (uiState.currentTab == AppNavTab.TABLES) Icons.Filled.TableBar else Icons.Outlined.TableBar,
                            contentDescription = "Meja",
                            modifier = Modifier.size(22.dp)
                        )
                    },
                    label = { Text("Meja", fontSize = 11.sp, fontWeight = FontWeight.SemiBold) },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = AmberPrimary,
                        selectedTextColor = AmberPrimary,
                        indicatorColor = com.example.ui.theme.PurpleSecondaryContainer
                    ),
                    modifier = Modifier.testTag("nav_tables")
                )

                NavigationBarItem(
                    selected = uiState.currentTab == AppNavTab.TRANSACTIONS,
                    onClick = { viewModel.setTab(AppNavTab.TRANSACTIONS) },
                    icon = {
                        Icon(
                            imageVector = if (uiState.currentTab == AppNavTab.TRANSACTIONS) Icons.Filled.ReceiptLong else Icons.Outlined.ReceiptLong,
                            contentDescription = "Riwayat",
                            modifier = Modifier.size(22.dp)
                        )
                    },
                    label = { Text("Riwayat", fontSize = 11.sp, fontWeight = FontWeight.SemiBold) },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = AmberPrimary,
                        selectedTextColor = AmberPrimary,
                        indicatorColor = com.example.ui.theme.PurpleSecondaryContainer
                    ),
                    modifier = Modifier.testTag("nav_transactions")
                )

                NavigationBarItem(
                    selected = uiState.currentTab == AppNavTab.REPORTS,
                    onClick = { viewModel.setTab(AppNavTab.REPORTS) },
                    icon = {
                        Icon(
                            imageVector = if (uiState.currentTab == AppNavTab.REPORTS) Icons.Filled.Assessment else Icons.Outlined.Assessment,
                            contentDescription = "Laporan",
                            modifier = Modifier.size(22.dp)
                        )
                    },
                    label = { Text("Laporan", fontSize = 11.sp, fontWeight = FontWeight.SemiBold) },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = AmberPrimary,
                        selectedTextColor = AmberPrimary,
                        indicatorColor = com.example.ui.theme.PurpleSecondaryContainer
                    ),
                    modifier = Modifier.testTag("nav_reports")
                )

                NavigationBarItem(
                    selected = uiState.currentTab == AppNavTab.MENU_MANAGEMENT,
                    onClick = { viewModel.setTab(AppNavTab.MENU_MANAGEMENT) },
                    icon = {
                        Icon(
                            imageVector = if (uiState.currentTab == AppNavTab.MENU_MANAGEMENT) Icons.Filled.RestaurantMenu else Icons.Outlined.RestaurantMenu,
                            contentDescription = "Menu",
                            modifier = Modifier.size(22.dp)
                        )
                    },
                    label = { Text("Menu", fontSize = 11.sp, fontWeight = FontWeight.SemiBold) },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = AmberPrimary,
                        selectedTextColor = AmberPrimary,
                        indicatorColor = com.example.ui.theme.PurpleSecondaryContainer
                    ),
                    modifier = Modifier.testTag("nav_menu_manage")
                )
            }
        }
    ) { innerPadding ->
        when (uiState.currentTab) {
            AppNavTab.POS_CASHIER -> PosScreen(
                uiState = uiState,
                categories = categories,
                menus = filteredMenus,
                tables = tables,
                viewModel = viewModel,
                onNavigateToTables = { viewModel.setTab(AppNavTab.TABLES) },
                modifier = Modifier.padding(innerPadding)
            )

            AppNavTab.TABLES -> TableScreen(
                tables = tables,
                orders = orders,
                viewModel = viewModel,
                modifier = Modifier.padding(innerPadding)
            )

            AppNavTab.TRANSACTIONS -> TransactionHistoryScreen(
                orders = orders,
                viewModel = viewModel,
                modifier = Modifier.padding(innerPadding)
            )

            AppNavTab.REPORTS -> ReportScreen(
                orders = orders,
                modifier = Modifier.padding(innerPadding)
            )

            AppNavTab.MENU_MANAGEMENT -> MenuManagementScreen(
                categories = categories,
                menus = filteredMenus,
                viewModel = viewModel,
                modifier = Modifier.padding(innerPadding)
            )
        }
    }

    // Offline Payment Modal (Cash, QRIS, EDC)
    if (uiState.showPaymentDialog) {
        PaymentModal(
            uiState = uiState,
            activeSettleOrder = uiState.activeSettleOrder,
            onDismiss = { viewModel.closePaymentDialog() },
            onConfirmPayment = { method, amountPaid, isPaidNow, notes ->
                viewModel.processPayment(method, amountPaid, isPaidNow, notes)
            },
            onConfirmSettle = { orderId, method, amountPaid ->
                viewModel.processSettlePending(orderId, method, amountPaid)
            }
        )
    }

    // Digital Thermal Receipt Modal
    if (uiState.showReceiptDialog && uiState.lastCompletedOrder != null) {
        ReceiptModal(
            orderWithItems = uiState.lastCompletedOrder!!,
            onDismiss = { viewModel.closeReceiptDialog() }
        )
    }
}
