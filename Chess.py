import pygame
import sys

# Initialize Pygame
pygame.init()

# Constants
WINDOW_SIZE = 800
SQUARE_SIZE = WINDOW_SIZE // 8
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
BROWN = (139, 69, 19)
BEIGE = (245, 222, 179)

# Set up the display
screen = pygame.display.set_mode((WINDOW_SIZE, WINDOW_SIZE))
pygame.display.set_caption("Chess")

# Initialize chess pieces
def load_pieces():
    pieces = {}
    colors = ['white', 'black']
    piece_types = ['king', 'queen', 'bishop', 'knight', 'rook', 'pawn']
    
    for color in colors:
        for piece in piece_types:
            try:
                image = pygame.image.load(f"pieces/{color}_{piece}.png")
                pieces[f"{color}_{piece}"] = pygame.transform.scale(image, (SQUARE_SIZE, SQUARE_SIZE))
            except:
                # If images are not available, use text representation
                pieces[f"{color}_{piece}"] = None
    return pieces

# Initial board setup
def initial_board():
    board = [[None for _ in range(8)] for _ in range(8)]
    
    # Set up pawns
    for i in range(8):
        board[1][i] = "black_pawn"
        board[6][i] = "white_pawn"
    
    # Set up other pieces (switched king and queen positions)
    piece_order = ["rook", "knight", "bishop", "king", "queen", "bishop", "knight", "rook"]
    for i in range(8):
        board[0][i] = f"black_{piece_order[i]}"
        board[7][i] = f"white_{piece_order[i]}"
    
    return board

def draw_board(screen, board, pieces):
    for row in range(8):
        for col in range(8):
            # Draw squares
            color = BEIGE if (row + col) % 2 == 0 else BROWN
            pygame.draw.rect(screen, color, (col * SQUARE_SIZE, row * SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE))
            
            # Draw pieces
            piece = board[row][col]
            if piece and pieces[piece]:
                screen.blit(pieces[piece], (col * SQUARE_SIZE, row * SQUARE_SIZE))
            elif piece:  # If image not available, draw text
                font = pygame.font.Font(None, 36)
                # Show full name for all pieces
                piece_name = piece.split('_')[1].upper()  # Get the piece name (e.g., 'PAWN', 'ROOK', etc.)
                text_surface = font.render(piece_name, True, BLACK if piece.startswith('white') else WHITE)
                text_rect = text_surface.get_rect(center=(col * SQUARE_SIZE + SQUARE_SIZE//2, 
                                                        row * SQUARE_SIZE + SQUARE_SIZE//2))
                screen.blit(text_surface, text_rect)

def is_path_clear(board, start_row, start_col, end_row, end_col):
    # Check if path is clear for sliding pieces (rook, bishop, queen)
    row_step = 0 if start_row == end_row else (end_row - start_row) // abs(end_row - start_row)
    col_step = 0 if start_col == end_col else (end_col - start_col) // abs(end_col - start_col)
    
    current_row = start_row + row_step
    current_col = start_col + col_step
    
    while current_row != end_row or current_col != end_col:
        if board[current_row][current_col] is not None:
            return False
        current_row += row_step
        current_col += col_step
    
    return True

def is_valid_pawn_move(old_row, old_col, new_row, new_col, piece, board, game_state):
    direction = -1 if piece.startswith('white') else 1
    starting_row = 6 if piece.startswith('white') else 1
    
    # Forward moves
    if new_col == old_col:
        if new_row == old_row + direction and board[new_row][new_col] is None:
            return True
        if old_row == starting_row and new_row == old_row + (2 * direction):
            if board[old_row + direction][old_col] is None and board[new_row][new_col] is None:
                game_state.last_move = (old_row, old_col, new_row, new_col)
                return True
    
    # Diagonal captures
    if abs(new_col - old_col) == 1 and new_row == old_row + direction:
        if board[new_row][new_col] is not None and board[new_row][new_col].startswith('black' if piece.startswith('white') else 'white'):
            return True
    
    # En passant
    if game_state.last_move:
        last_start_row, last_start_col, last_end_row, last_end_col = game_state.last_move
        if (abs(last_end_row - last_start_row) == 2 and  # Last move was a two-square pawn move
            'pawn' in board[last_end_row][last_end_col] and  # Last moved piece was a pawn
            abs(new_col - last_end_col) == 1 and  # Capturing diagonally
            new_row == last_end_row):  # Moving to the same row as the pawn to be captured
            return True
    
    return False

def is_valid_rook_move(old_row, old_col, new_row, new_col, board):
    if old_row == new_row or old_col == new_col:
        return is_path_clear(board, old_row, old_col, new_row, new_col)
    return False

def is_valid_knight_move(old_row, old_col, new_row, new_col, board):
    row_diff = abs(new_row - old_row)
    col_diff = abs(new_col - old_col)
    return (row_diff == 2 and col_diff == 1) or (row_diff == 1 and col_diff == 2)

def is_valid_bishop_move(old_row, old_col, new_row, new_col, board):
    if abs(new_row - old_row) == abs(new_col - old_col):
        return is_path_clear(board, old_row, old_col, new_row, new_col)
    return False

def is_valid_queen_move(old_row, old_col, new_row, new_col, board):
    if (old_row == new_row or old_col == new_col or 
        abs(new_row - old_row) == abs(new_col - old_col)):
        return is_path_clear(board, old_row, old_col, new_row, new_col)
    return False

def is_valid_king_move(old_row, old_col, new_row, new_col, board, game_state):
    # Normal king move
    row_diff = abs(new_row - old_row)
    col_diff = abs(new_col - old_col)
    if row_diff <= 1 and col_diff <= 1:
        return True
    
    # Castling
    if row_diff == 0 and col_diff == 2:
        if old_row == 7:  # White king
            if not game_state.white_king_moved:
                if new_col > old_col and not game_state.white_rooks_moved[1]:  # Kingside
                    return is_path_clear(board, old_row, old_col, old_row, 7)
                elif new_col < old_col and not game_state.white_rooks_moved[0]:  # Queenside
                    return is_path_clear(board, old_row, old_col, old_row, 0)
        else:  # Black king
            if not game_state.black_king_moved:
                if new_col > old_col and not game_state.black_rooks_moved[1]:  # Kingside
                    return is_path_clear(board, old_row, old_col, old_row, 7)
                elif new_col < old_col and not game_state.black_rooks_moved[0]:  # Queenside
                    return is_path_clear(board, old_row, old_col, old_row, 0)
    
    return False

def is_in_check(board, color, game_state):
    # Find king position
    king_pos = None
    for row in range(8):
        for col in range(8):
            if board[row][col] == f"{color}_king":
                king_pos = (row, col)
                break
        if king_pos:
            break
    
    if not king_pos:
        return False
    
    # Check if any opponent piece can capture the king
    for row in range(8):
        for col in range(8):
            piece = board[row][col]
            if piece and piece.startswith('black' if color == 'white' else 'white'):
                if is_valid_move(row, col, king_pos[0], king_pos[1], piece, board, game_state):
                    return True
    return False

def is_valid_move(old_row, old_col, new_row, new_col, piece, board, game_state):
    # Ensure indices are within bounds
    if not (0 <= new_row < 8 and 0 <= new_col < 8):
        print(f"Invalid move: target position {(new_row, new_col)} is out of bounds")  # Debugging
        return False

    # Check if target square has a piece of the same color
    target_piece = board[new_row][new_col]
    if target_piece and target_piece.startswith(piece.split('_')[0]):
        print(f"Invalid move: cannot capture own piece at {new_row}, {new_col}")  # Debugging
        return False
        
    if 'pawn' in piece:
        return is_valid_pawn_move(old_row, old_col, new_row, new_col, piece, board, game_state)
    elif 'rook' in piece:
        return is_valid_rook_move(old_row, old_col, new_row, new_col, board)
    elif 'knight' in piece:
        return is_valid_knight_move(old_row, old_col, new_row, new_col, board)
    elif 'bishop' in piece:
        return is_valid_bishop_move(old_row, old_col, new_row, new_col, board)
    elif 'queen' in piece:
        return is_valid_queen_move(old_row, old_col, new_row, new_col, board)
    elif 'king' in piece:
        return is_valid_king_move(old_row, old_col, new_row, new_col, board, game_state)
    return False

def make_move(board, old_row, old_col, new_row, new_col, game_state):
    piece = board[old_row][old_col]
    color = piece.split('_')[0]
    
    # Update castling flags
    if 'king' in piece:
        if color == 'white':
            game_state.white_king_moved = True
        else:
            game_state.black_king_moved = True
    elif 'rook' in piece:
        if color == 'white':
            if old_col == 0:
                game_state.white_rooks_moved[0] = True
            elif old_col == 7:
                game_state.white_rooks_moved[1] = True
        else:
            if old_col == 0:
                game_state.black_rooks_moved[0] = True
            elif old_col == 7:
                game_state.black_rooks_moved[1] = True
    
    # Handle castling
    if 'king' in piece and abs(new_col - old_col) == 2:
        rook_col = 7 if new_col > old_col else 0
        rook_new_col = 5 if new_col > old_col else 3
        rook_row = 7 if color == 'white' else 0
        board[rook_row][rook_new_col] = board[rook_row][rook_col]
        board[rook_row][rook_col] = None
    
    # Handle en passant
    if 'pawn' in piece and abs(new_col - old_col) == 1 and board[new_row][new_col] is None:
        captured_pawn_row = old_row
        board[captured_pawn_row][new_col] = None
    
    # Make the move
    board[new_row][new_col] = piece
    board[old_row][old_col] = None

# Game state
class GameState:
    def __init__(self):
        self.board = initial_board()
        self.current_player = 'white'  # white moves first
        self.last_move = None  # for en passant
        self.white_king_moved = False
        self.black_king_moved = False
        self.white_rooks_moved = [False, False]  # [left rook, right rook]
        self.black_rooks_moved = [False, False]  # [left rook, right rook]

def draw_valid_moves(screen, board, selected_pos, selected_piece, game_state):
    if selected_pos is None or selected_piece is None:
        return
        
    old_row, old_col = selected_pos
    print(f"Selected piece: {selected_piece} at position: {selected_pos}")  # Debugging
    
    # Check all squares on the board
    for row in range(8):
        for col in range(8):
            if is_valid_move(old_row, old_col, row, col, selected_piece, board, game_state):
                # Create a semi-transparent green surface for valid moves
                s = pygame.Surface((SQUARE_SIZE, SQUARE_SIZE))
                s.set_alpha(64)  # More transparent than the selected piece highlight
                s.fill((0, 255, 0))  # Green color
                screen.blit(s, (col * SQUARE_SIZE, row * SQUARE_SIZE))

def main():
    pieces = load_pieces()
    game_state = GameState()
    selected_piece = None
    selected_pos = None
    
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
                
            if event.type == pygame.MOUSEBUTTONDOWN:
                x, y = pygame.mouse.get_pos()
                col = x // SQUARE_SIZE
                row = y // SQUARE_SIZE
                
                if selected_piece is None:
                    if 0 <= row < 8 and 0 <= col < 8:  # Ensure click is within bounds
                        piece = game_state.board[row][col]
                        if piece and piece.startswith(game_state.current_player):
                            selected_piece = piece
                            selected_pos = (row, col)
                            print(f"Piece selected: {selected_piece} at {selected_pos}")  # Debugging
                else:
                    old_row, old_col = selected_pos
                    print(f"Attempting move from {selected_pos} to {(row, col)}")  # Debugging
                    if is_valid_move(old_row, old_col, row, col, selected_piece, game_state.board, game_state):
                        # Make a temporary move to check if it puts/leaves king in check
                        temp_board = [r[:] for r in game_state.board]  # Correctly copy the board
                        make_move(temp_board, old_row, old_col, row, col, game_state)
                        
                        if not is_in_check(temp_board, game_state.current_player, game_state):
                            print(f"Move from {selected_pos} to {(row, col)} is valid")  # Debugging
                            make_move(game_state.board, old_row, old_col, row, col, game_state)
                            game_state.current_player = 'black' if game_state.current_player == 'white' else 'white'
                        else:
                            print(f"Move from {selected_pos} to {(row, col)} leaves king in check")  # Debugging
                    else:
                        print(f"Move from {selected_pos} to {(row, col)} is invalid")  # Debugging
                    
                    selected_piece = None
                    selected_pos = None
        
        screen.fill(WHITE)
        draw_board(screen, game_state.board, pieces)
        
        # Draw valid moves first (underneath the selected piece highlight)
        draw_valid_moves(screen, game_state.board, selected_pos, selected_piece, game_state)
        
        # Highlight selected piece (on top of valid moves)
        if selected_pos:
            row, col = selected_pos
            s = pygame.Surface((SQUARE_SIZE, SQUARE_SIZE))
            s.set_alpha(128)
            s.fill((255, 255, 0))
            screen.blit(s, (col * SQUARE_SIZE, row * SQUARE_SIZE))
        
        pygame.display.flip()

if __name__ == "__main__":
    main()
