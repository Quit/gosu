//! \file Font.hpp
//! Interface of the Font class.

#ifndef GOSU_FONT_HPP
#define GOSU_FONT_HPP

#include <Gosu/Fwd.hpp>
#include <Gosu/Color.hpp>
#include <Gosu/GraphicsBase.hpp>
#include <Gosu/Platform.hpp>
#include <Gosu/TR1.hpp>
#include <string>

namespace Gosu
{
    //! A font can be used to draw text on a Graphics object very flexibly.
    //! Fonts are ideal for small texts that change regularly. For large,
    //! static texts you should use createBitmap and turn the result into
    //! an image.
    class Font
    {
        struct Impl;
        std::tr1::shared_ptr<Impl> pimpl;

    public:
        //! Constructs a font that can be drawn onto the graphics object.
        //! \param fontName Name of a system font, or a filename to a TTF
        //!        file (must contain '/', does not work on Linux).
        //! \param fontHeight Height of the font, in pixels.
        //! \param fontFlags Flags used to render individual characters of
        //!        the font.
        Font(Graphics& graphics, const std::wstring& fontName,
            unsigned fontHeight, unsigned fontFlags = ffBold);
        
        //! Returns the name of the font that was used to create it.
        std::wstring name() const;
        
        //! Returns the height of the font, in pixels.
        unsigned height() const;
        
        //! Returns the flags used to create the font characters.
        unsigned flags() const;
        
        //! Returns the width, in pixels, the given text would occupy if drawn.
        double textWidth(const std::wstring& text, double factorX = 1) const;
        
        //! Returns the width, in pixels, the given text with those flags
        //! would occupy if drawn.
        double textWidthDefined(const std::wstring& text, int bold = 0, int underline = 0, int italic = 0, double factorX = 1.0) const;

        //! Draws text so the top left corner of the text is at (x; y).
        //! \param text Formatted text without line-breaks.
        void draw(const std::wstring& text, double x, double y, ZPos z,
            double factorX = 1, double factorY = 1,
            Color c = Color::WHITE, AlphaMode mode = amDefault) const;
        
        //! Draws text so the top left corner of the text is at (x; y).
        //! Unlike draw, this function ignores the default font flags
        //! and is behaving as if that many tags have been opened.
        //! \param text Formatted text without line-breaks.
        //! \param bold Amount of <b> tags opened.
        //! \param underline Amount of <u> tags opened.
        //! \param italic Amount of <i> tags opened.
        void drawDefined(const std::wstring& text, double x, double y, ZPos z,
            double factorX = 1, double factorY = 1,
            int bold = 0, int underline = 0, int italic = 0,
            Color c = Color::WHITE, AlphaMode mode = amDefault) const;

        //! Draws text at a position relative to (x; y).
        //! \param relX Determines where the text is drawn horizontally. If
        //! relX is 0.0, the text will be to the right of x, if it is 1.0,
        //! the text will be to the left of x, if it is 0.5, it will be
        //! centered on x. Of course, all real numbers are possible values.
        //! \param relY See relX.
        void drawRel(const std::wstring& text, double x, double y, ZPos z,
            double relX, double relY, double factorX = 1, double factorY = 1,
            Color c = Color::WHITE, AlphaMode mode = amDefault) const;
        
        //! Maps a letter to a specific image instead of generating one using
        //! Gosu's built-in text rendering. This can only be called once per
        //! character, and the character must not have been drawn before.
        //! This ensures that Fonts are still sort of immutable.
        void setImage(wchar_t wc, unsigned fontFlags, const Gosu::Image& image);
        //! A shortcut for mapping a character to an image regardless of fontFlags.
        //! Later versions might apply faux italics or faux bold to it (to be decided!).
        void setImage(wchar_t wc, const Gosu::Image& image);
        
        #ifndef SWIG
        GOSU_DEPRECATED
        #endif
        //! DEPRECATED: Analogous to draw, but rotates the text by a given angle. Use 
        //! a simple pushTransform to achieve the same effect.
        void drawRot(const std::wstring& text, double x, double y, ZPos z, double angle,
            double factorX = 1, double factorY = 1,
            Color c = Color::WHITE, AlphaMode mode = amDefault) const;
    };
}

#endif
